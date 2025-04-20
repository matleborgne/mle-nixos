{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.nspawn.nextcloud.enable = lib.mkOption {
    description = "Configure nextcloud nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.nspawn.nextcloud.enable (

    let
      address = [ "10.22.0.153/24" ]; # change this accord to desired local IP

    in {

      containers.nextcloud = {
        autoStart = true;
        ephemeral = false;
        privateNetwork = false;
        macvlans = [ "enp3s0" ];

        bindMounts = {
          "/var/lib/nextcloud" = { hostPath = "/var/lib/nspawn/nextcloud/app"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "/var/lib/nspawn/nextcloud/db"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
          "/ncpassfile" = { hostPath = "/etc/nixos/build/secrets/keys/nextcloud_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, ... }: {

          imports = [
            ../apps/nextcloud.nix
            ../apps/fish.nix
          ];
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Main services
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [ "d /var/lib/nextcloud 700 nextcloud nextcloud -" ];

          mle = {
            apps = {
              nextcloud.enable = true;
              fish.enable = true;
            };
          };

          # Customisation for container
          services.nextcloud = {
            # Very sensitive Nextcloud-installer about trusted domain : only IP without mask or anything else
            settings = { trusted_domains = [ (builtins.elemAt (builtins.split "/" (builtins.elemAt address 0)) 0) ]; };
            config = { adminpassFile = "/ncpassfile"; };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Network
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          system.stateVersion = "24.11";

          networking = {
            hostName = "nextcloud";

            useNetworkd = true;
            useDHCP = false;
            useHostResolvConf = false;
          };

          systemd.network = {
            enable = true;
            networks = {
              "40-mv-enp3s0" = {
                matchConfig.Name = "mv-enp3s0";
                networkConfig.DHCP = "yes";
                dhcpV4Config.ClientIdentifier = "mac";
                inherit address;
              };
            };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Auto Backup
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          environment.systemPackages = with pkgs; [ restic ];

          services.restic.backups = {

            nextcloud-app = {
              initialize = false;
              repository = "/mnt/nfs/bkp/lxc/553-nextcloud/app";
              paths = [ "/var/lib/nextcloud" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Wed 05:30";
                Persistent = "true";
              };
            };

            nextcloud-db = {
              initialize = false;
              repository = "/mnt/nfs/bkp/lxc/553-nextcloud/db";
              paths = [ "/var/lib/postgresql" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Wed 07:30";
                Persistent = "true";
              };
            };

          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Other services
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        };
      };
  });
}
