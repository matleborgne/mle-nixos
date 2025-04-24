{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

    # /!\ Specifications for Nextcloud APP :
    # For first installation, to not being stuck without account :
    # Enter nixos container : nixos-container root-login nextcloud
    # Re-enable root account : nextcloud-occ user:enable root
    # This is not needed if an account already exist (backup, etc.)

{

  options.mle.containers.nspawn.nextcloud.enable = lib.mkOption {
    description = "Configure nextcloud nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.nextcloud.enable (

    let
      name = "nextcloud";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).nextcloud;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /var/lib/nextcloud/app - - - -"
        "d /var/lib/nextcloud/db - - - -"
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
          "/var/lib/nextcloud" = { hostPath = "/var/lib/nextcloud/app"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "/var/lib/nextcloud/db"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
          "/ncpassfile" = { hostPath = "/etc/nixos/build/secrets/keys/nextcloud_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [
            "d /var/lib/nextcloud 700 nextcloud nextcloud -"
            "d /var/lib/postgresql - - - -"
          ];

          imports = [
            ../../apps/nextcloud.nix
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps = {
              nextcloud.enable = true;
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
            };
          };

          # Customisation for container
          services.nextcloud = {
            # Very sensitive Nextcloud-installer about trusted domain : only IP without mask or anything else
            settings = { trusted_domains = [ (builtins.elemAt (builtins.split "/" (builtins.elemAt address 0)) 0) ]; };
            config = { adminpassFile = "/ncpassfile"; };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
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



        };
      };
  });
}
