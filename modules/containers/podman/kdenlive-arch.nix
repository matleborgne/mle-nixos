{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{

  options.mle.containers.podman.kdenlive-arch.enable = lib.mkOption {
    description = "Configure podman kdenlive container";
    type = lib.types.bool;
    default = false;
  };

  imports = lib.optional (builtins.pathExists ../../../secrets/podman/kdenlive-arch.nix) ../../../secrets/podman/kdenlive-arch.nix;

  config = lib.mkIf config.mle.containers.podman.kdenlive-arch.enable (

    let
      cname = "kdenlive-arch";

      containerfile = pkgs.writeText "Containerfile" ''
        FROM archlinux
        RUN sed -i '\|NoExtract.*usr/share/i18n/\*|d' /etc/pacman.conf
        RUN pacman -Syu --noconfirm kdenlive xkeyboard-config libpulse glibc
        RUN pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/*
        RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
        
      '';

      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
      user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");
      uid = toString config.users.users.${user}.uid;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.podman.enable = true;
      

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
            WAYLAND_DISPLAY    = "wayland-0";
            XDG_RUNTIME_DIR    = "/run/user/${uid}";
            HOME               = "/home/${user}";
          };

          volumes = [
            "/run/user/${uid}/wayland-0:/run/user/${uid}/wayland-0:U"
            "/run/user/${uid}/pulse:/run/user/${uid}/pulse:U"
            "/run/user/${uid}/dconf:/run/user/${uid}/dconf:U"
            "/run/user/${uid}/bus:/run/user/${uid}/bus:U"
          ];

          extraOptions = [
            "--interactive" "--tty" "--userns=keep-id"
            "--cap-drop=CAP_AUDIT_WRITE" "--cap-drop=CAP_MKNOD" "--cap-drop=CAP_NET_RAW"
            "--network=pasta" "--security-opt=no-new-privileges"
          ];

          entrypoint = "/bin/sh";
          cmd = [ "-c" "LC_ALL=fr_FR.UTF-8 exec /usr/bin/kdenlive" ];

        };
      };

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Fine tuning
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        systemd.services."podman-${cname}" = {
          serviceConfig.User = lib.mkForce user;
          serviceConfig.Restart = lib.mkForce "no";
          after = [ "build-${cname}.service" ];
          requires = [ "build-${cname}.service" ];
        };

  });
}
