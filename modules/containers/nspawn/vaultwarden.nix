{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.vaultwarden.enable = lib.mkOption {
    description = "Configure vaultwarden nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.vaultwarden.enable (

    let
      name = "vaultwarden";
      address = [ "10.22.0.151/24" ]; # change this accord to desired local IP

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
          "/var/lib/vaultwarden" = { hostPath = "/var/lib/vaultwarden"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-enp3s0" = { inherit address; };

          imports = [
            ../../apps/vaultwarden.nix
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          mle = {
            apps = {
              vaultwarden.enable = true;
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

            vaultwarden = {
              initialize = false;
              repository = "/mnt/nas/bkp/lxc/551-vaultwarden";
              paths = [ "/var/lib/vaultwarden" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-daily 10 --keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "05:05";
                Persistent = "true";
              };
            };

          };



        };
      };
  });
}
