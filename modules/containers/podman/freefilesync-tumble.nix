{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{

  options.mle.containers.podman.freefilesync-tumble.enable = lib.mkOption {
    description = "Configure podman freefilesync container";
    type = lib.types.bool;
    default = false;
  };

  imports = lib.optional (builtins.pathExists ../../../secrets/podman/freefilesync-tumble.nix) ../../../secrets/podman/freefilesync-tumble.nix;

  config = lib.mkIf config.mle.containers.podman.freefilesync-tumble.enable (

    let
      cname = "freefilesync-tumble";

      containerfile = pkgs.writeText "Containerfile" ''
        FROM opensuse/tumbleweed:latest
        RUN zypper --non-interactive addrepo --refresh \
          https://download.opensuse.org/repositories/network/openSUSE_Tumbleweed/ freefilesync-repo
        RUN zypper --gpg-auto-import-keys refresh && \
          zypper --non-interactive install FreeFileSync \
            gtk3 fontconfig dejavu-fonts gsettings-desktop-schemas hicolor-icon-theme ubuntu-fonts
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
            GDK_DPI_SCALE      = "1.3";
          };

          volumes = [
            "/run/user/${uid}/wayland-0:/run/user/${uid}/wayland-0:U"
            "/run/user/${uid}/pulse:/run/user/${uid}/pulse:U"
            "/run/user/${uid}/dconf:/run/user/${uid}/dconf:U"
            "/run/user/${uid}/bus:/run/user/${uid}/bus:U"
          ];

          extraOptions = [
            "--interactive" "--tty" "--read-only" "--userns=keep-id"
            "--network=host" "--security-opt=no-new-privileges"
          ];

          entrypoint = "/usr/bin/FreeFileSync";

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
