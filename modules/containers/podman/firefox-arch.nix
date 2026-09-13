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

      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
      user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");
      uid = toString config.users.users.${user}.uid;

      containerfile = pkgs.writeText "Containerfile" ''
        FROM archlinux
        RUN pacman -Syu --noconfirm firefox xkeyboard-config libpulse
        RUN pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/*
      '';

      quadletfile = pkgs.writeText "Quadletfile" ''
        [Unit]
        After=build-${cname}.service
        Requires=build-${cname}.service

        [Install]
        WantedBy=default.target

        [Container]
        ContainerName=firefox-arch
        Image=localhost/firefox-arch
        User=${uid}
        Group=${uid}

        PodmanArgs=--interactive --tty --userns=keep-id --read-only
        DropCapability=CAP_AUDIT_WRITE CAP_MKNOD CAP_NET_RAW
        NoNewPrivileges=true
        Network=pasta

        Environment=WAYLAND_DISPLAY XDG_RUNTIME_DIR HOME
        Environment=PULSE_SERVER=unix:/run/user/${uid}/pulse/native
        Environment=XDG_DATA_DIRS=/usr/share
        Environment=MOZ_ENABLE_WAYLAND=1

        Volume=/run/user/${uid}/wayland-0:/run/user/${uid}/wayland-0:U
        Volume=/run/user/${uid}/pulse:/run/user/${uid}/pulse:U
        Volume=/run/user/${uid}/dconf:/run/user/${uid}/dconf:U

        Exec=/usr/bin/firefox --name firefox-arch
      '';

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.podman.enable = true;
      

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      systemd.user.services."build-${cname}" = {
        description = "Build ${cname} podman image";
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;    
        };
        script = ''
          podman build -t localhost/${cname} -f ${containerfile}
        '';
        wantedBy = [ "default.target" ];
      };

      
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Quadlet build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      systemd.user.tmpfiles.rules = [
        "d %h/.config/containers/systemd 0755 - - -"
        "L+ %h/.config/containers/systemd/${cname}.container - - - - ${quadletfile}"
      ];

  });
}
