{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.rclone-cloud.enable = lib.mkOption {
    description = "Configure rclone-cloud nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.rclone-cloud.enable (

    let
      name = "rclone-cloud";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).rclone-cloud;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /srv - - - -"
        "d /var/reverse - - - -"
        "d /var/lib/rclone - - - -"
      ];

      imports = [ ../../../secrets/gocryptfs-reverse.nix ];


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container structure
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      containers.${name} = {

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = net.ifaceList;

        bindMounts = {
          "/mnt/nas" = { hostPath = "/srv"; isReadOnly = false; };
          "/mnt/reverse" = { hostPath = "/var/reverse"; isReadOnly = false; };
          "/var/lib/rclone" = { hostPath = "/var/lib/rclone"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, mle, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [
            "d /var/lib/rclone - - - -"
            "d /mnt/nas - - - -"
            "d /mnt/uncrypt - - - -"
            "d /mnt/reverse - - - -"
          ];

          environment.sessionVariables = { RCLONE_CONFIG = "/var/lib/rclone/rclone.conf"; };

          imports = [
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps.fish.enable = true;
            misc.networkd.enable = true;
          };


          environment.systemPackages = with pkgs; [
            bat rclone restic gocryptfs
          ];


          systemd.services."rclone" = {
            wantedBy = [ "multi-user.target" ];
            path = [ pkgs.bash ];
            script = ''
              /var/lib/rclone/start-services.sh
            '';
          };

          #systemd.timers."rclone" = {
          #  wantedBy = [ "timers.target" ];
          #  timerConfig = {
          #    OnCalendar = "*:*";
          #    Unit = "rclone.service";
          #  };
          #};


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Ensure USER 1000
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          users.users.rclone = {
            isNormalUser = true;
            uid = 1000;
            extraGroups = [ "udev" "users" "fuse" ];
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          services.restic.backups = {

            rclone = {
              initialize = false;
              repository = "/mnt/nas/bkp/lxc/558-rclone-cloud";
              paths = [ "/var/lib/rclone" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-daily 8" "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Tue 05:45";
                Persistent = "true";
              };
            };

          };



        };
      };
  });
}
