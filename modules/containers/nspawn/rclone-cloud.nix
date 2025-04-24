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
      address = [ "10.22.0.158/24" ]; # change this accord to desired local IP

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /var/lib/rclone - - - -"
      ];


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container structure
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      containers.${name} = {

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = net.ifaceList;

        bindMounts = {
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

          #networking.firewall.enable = false;

          environment.systemPackages = with pkgs; [
            bat gocryptfs rclone restic
          ];

          systemd.services."rclone" = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''${pkgs.bash}/bin/bash /var/lib/rclone/start-services.sh'';
            };
          };

          systemd.timers."rclone" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "01:08";
              Unit = "rclone.service";
            };
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
