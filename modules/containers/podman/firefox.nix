{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{

  options.mle.containers.podman.firefox-arch.enable = lib.mkOption {
    description = "Configure podman firefox container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.podman.firefox-arch.enable (

    let
      containerfile = pkgs.writeText "Containerfile" ''
        FROM archlinux
        RUN pacman -Syu --noconfirm wget gnupg ca-certificates xkeyboard-config firefox
        RUN pacman -Syu --noconfirm pulseaudio pavucontrol alsa-utils
        RUN pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/*
      '';

      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
      user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      virtualisation.podman.enable = true;
      

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      systemd.services.build-firefox-arch = {
        description = "Build firefox-arch podman image";
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = user;     
        };
        script = ''
          podman build -t localhost/firefox-arch -f ${containerfile}
        '';
        wantedBy = [ "multi-user.target" ];
      };

      
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Quadlet build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      virtualisation.oci-containers = {
        backend = "podman";
        containers.firefox = {
          image = "localhost/firefox-arch";
          autoStart = false;
          user = "1000:1000";

          environment = {
            PULSE_SERVER       = "unix:/run/user/1000/pulse/native";
            XDG_DATA_DIRS      = "/usr/share";
            MOZ_ENABLE_WAYLAND = "1";
            WAYLAND_DISPLAY    = "wayland-0";
            XDG_RUNTIME_DIR    = "/run/user/1000";
            HOME               = "/home/${user}";
          };

          volumes = [
            "/run/user/1000/wayland-0:/run/user/1000/wayland-0:U"
            "/run/user/1000/pulse:/run/user/1000/pulse:U"
            "/run/user/1000/pipewire-0:/run/user/1000/pipewire-0:U"
            "/run/user/1000/dconf:/run/user/1000/dconf:U"
          ];

          extraOptions = [
            "--interactive" "--tty" "--read-only" "--userns=keep-id"
            "--cap-drop=CAP_AUDIT_WRITE" "--cap-drop=CAP_MKNOD" "--cap-drop=CAP_NET_RAW"
            "--network=pasta" "--security-opt=no-new-privileges"
          ];

          entrypoint = "/usr/bin/firefox";
          cmd = [ "--name" "firefox-arch" ];

        };
      };

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Deploy order verification
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        systemd.services."podman-firefox" = {
          serviceConfig.User = lib.mkForce user;
          after = [ "build-firefox-arch.service" ];
          requires = [ "build-firefox-arch.service" ];
        };

  });
}
