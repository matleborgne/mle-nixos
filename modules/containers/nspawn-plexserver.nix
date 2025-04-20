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
      containerIp = "10.22.0.175";

    in {

  containers.plexserver = {
    autoStart = true;
    ephemeral = false;
    privateNetwork = false;
    macvlans = [ "enp3s0" ];

    #bindMounts = {
    #  "/var/lib/plex" = { hostPath = "/var/lib/ct/plex"; isReadOnly = false; };
    #};

    config = { lib, config, pkgs, options, ... }: {
    #  systemd.tmpfiles.rules = [ "d /var/lib/plex 700 plex plex -" ];

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules> INSIDE THE CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    imports = [ ../apps/plexserver.nix ];
    mle.apps.plexserver.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Services and customization of CONTAINER
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
          address = [ "10.22.0.155/24" ];
        };
      };
    };


    };
  };
  });
}
