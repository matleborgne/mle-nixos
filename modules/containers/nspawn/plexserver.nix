{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.plexserver.enable = lib.mkOption {
    description = "Configure plexserver nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.plexserver.enable (

    let
      name = "plexserver";
      address = [ "10.22.0.152/24" ]; # change this accord to desired local IP

    in {

      containers.${name} = {

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Container structure
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = [ "enp3s0" ];

        bindMounts = {
          "/var/lib/plex" = { hostPath = "/var/lib/plex"; isReadOnly = false; };
          "/mnt/nfs" = { hostPath = "/var/srv"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, ... }: {

          imports = [
            ../../apps/plexserver.nix
            ../../apps/fish.nix
          ];
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          system.stateVersion = "24.11";

          networking.hostName = "$name";
          systemd.network.networks."40-mv-enp3s0" = { inherit address; };

          systemd.tmpfiles.rules = [ "d /var/lib/plex 700 plex plex -" ];

          mle = {
            apps = {
              plexserver.enable = true;
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

            plex = {
              initialize = false;
              repository = "/mnt/nfs/bkp/lxc/552-plexserver";
              paths = [ "/var/lib/plex" ];
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
