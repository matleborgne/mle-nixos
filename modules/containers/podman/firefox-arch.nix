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

  imports = lib.optional (builtins.pathExists ../../../secrets/podman/firefox-arch.nix) ../../../secrets/podman/firefox-arch.nix;

  config = lib.mkIf config.mle.containers.podman.firefox-arch.enable (

    let
      cname = "firefox-arch";

      containerfile = pkgs.writeText "Containerfile" ''
        FROM archlinux
        RUN pacman -Syu --noconfirm wget gnupg ca-certificates xkeyboard-config firefox
        RUN pacman -Syu --noconfirm pulseaudio pavucontrol alsa-utils
        RUN pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/*
      '';

      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
      user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");
      uid = toString config.users.users.${user}.uid;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      virtualisation.podman.enable = true;
      

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      systemd.services."build-${cname}" = {
        description = "Build ${cname} podman image";
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = lib.mkForce user;     
        };
        script = ''
          podman build -t localhost/${cname} -f ${containerfile} \
            --build-arg UID=${uid} --build-arg GID=${uid} --build-arg UNAME=${user}
        '';
        wantedBy = [ "multi-user.target" ];
      };

      
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Quadlet build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      virtualisation.oci-containers = {
        backend = "podman";
        containers.${cname} = {
          image = "localhost/${cname}";
          autoStart = false;
          user = "${uid}:${uid}";

          environment = {
            PULSE_SERVER       = "unix:/run/user/${uid}/pulse/native";
            XDG_DATA_DIRS      = "/usr/share";
            MOZ_ENABLE_WAYLAND = "1";
            WAYLAND_DISPLAY    = "wayland-0";
            XDG_RUNTIME_DIR    = "/run/user/${uid}";
            HOME               = "/home/${user}";
          };

          volumes = [
            "/run/user/${uid}/wayland-0:/run/user/${uid}/wayland-0:U"
            "/run/user/${uid}/pulse:/run/user/${uid}/pulse:U"
            "/run/user/${uid}/pipewire-0:/run/user/${uid}/pipewire-0:U"
            "/run/user/${uid}/dconf:/run/user/${uid}/dconf:U"
          ];

          extraOptions = [
            "--interactive" "--tty" "--read-only" "--userns=keep-id"
            "--cap-drop=CAP_AUDIT_WRITE" "--cap-drop=CAP_MKNOD" "--cap-drop=CAP_NET_RAW"
            "--network=pasta" "--security-opt=no-new-privileges"
          ];

          entrypoint = "/usr/bin/firefox";
          cmd = [ "--name" "${cname}" ];

        };
      };

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Deploy order verification
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        systemd.user.services."podman-${cname}" = {
          serviceConfig.User = lib.mkForce user;
          after = [ "build-${cname}.service" ];
          requires = [ "build-${cname}.service" ];
        };

  });
}
