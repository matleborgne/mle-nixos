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

  config = lib.mkIf config.mle.nspawn.plexserver.enable {

  networking.nat.forwardPorts = [
    { destination = "10.22.0.174:32400"; sourcePort = "32400"; }
  ];

  containers.plexserver = {
    autoStart = true;
    ephemeral = false;
    #bindMounts = {
    #  "/var/lib/plex" = { hostPath = "/var/lib/ct/plex"; isReadOnly = false; };
    #};

    privateNetwork = true;
    hostAddress = "10.22.0.174";  # change this
    localAddress = "10.22.0.175"; # change this, NOT THE SAME AS HOST ADDRESS

    config = { lib, config, pkgs, options, ... }: {
    #  systemd.tmpfiles.rules = [ "d /var/lib/plex 700 plex plex -" ];

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules> INSIDE THE CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #imports = [ ../apps/plexserver.nix ];
    #mle.apps.plexserver.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Services and customization of CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    system.stateVersion = "24.11";

    networking = {
      useHostResolvConf = lib.mkForce false;
    };

    services.resolved.enable = true;

    # Provisoire pour tester le bug
    #networking.firewall.enable = lib.mkForce false;
    #networking.defaultGateway = "10.22.0.1";
    #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    };
  };
  };
}
