{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.jellyfin.enable = lib.mkOption {
    description = "Configure jellyfin nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.jellyfin.enable (

    let
      name = "jellyfin";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).jellyfin;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /var/lib/jellyfin - - - -"
        "d /srv - - - -"
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
          "/var/lib/jellyfin" = { hostPath = "/var/lib/jellyfin"; isReadOnly = false; };
          "/srv/vid" = { hostPath = "/srv/vid"; isReadOnly = true; };
          "/srv/bkp/lxc/560-jellyfin" = { hostPath = "/srv/bkp/lxc/560-jellyfin"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [
            "d /var/lib/jellyfin 700 jellyfin jellyfin -"
            "d /srv/vid - - - -"
            "d /srv/bkp/lxc/560-jellyfin - - - -"
          ];

          imports = [
            ../../apps/jellyfin.nix
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps = {
              jellyfin.enable = true;
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
            };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          environment.systemPackages = with pkgs; [ restic ];

          services.restic.backups = {

            jellyfin = {
              initialize = false;
              repository = "/mnt/nfs/bkp/lxc/560-jellyfin";
              paths = [ "/var/lib/jellyfin" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Tue 05:25";
                Persistent = "true";
              };
            };

          };


        };
      };
  });
}
