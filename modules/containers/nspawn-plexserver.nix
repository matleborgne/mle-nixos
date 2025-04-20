{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.nspawn.plexserver.enable = lib.mkOption {
    description = "Configure plexserver nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.nspawn.plexserver.enable (

    let
      address = [ "10.22.0.155/24" ];

    in {

      containers.plexserver = {
        autoStart = true;
        ephemeral = false;
        privateNetwork = false;
        macvlans = [ "enp3s0" ];

        bindMounts = {
          "/var/lib/plex" = { hostPath = "/var/lib/ct/plex"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, ... }: {
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Defined services inside container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [ "d /var/lib/plex 700 plex plex -" ];

          imports = [ ../apps/plexserver.nix ];
          mle.apps.plexserver.enable = true;


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Container network
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          system.stateVersion = "24.11";

          networking = {
            hostName = "plexserver";

            useNetworkd = true;
            useDHCP = false;
            useHostResolvConf = false;

            firewall = {
              enable = lib.mkForce false;
            };
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

        };

      };
  });
}
