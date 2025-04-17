{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.ct.plexserver.enable = lib.mkOption {
    description = "Configure plexserver container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.ct.plexserver.enable {

  containers.plexserver = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.22.0.154";  # change this
    localAddress = "10.22.0.155"; # change this, NOT THE SAME AS HOST ADDRESS
    config = { lib, config, pkgs, ... }: {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules> INSIDE THE CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    imports = [ options.mle.apps.plexserver.nixosModule ];
    options.mle.apps.plexserver.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Services and customization of CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    system.stateVersion = "24.11";

    # TODO test if needed or not
    #networking.defaultGateway = "10.22.0.1";
    #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking = {
      useHostResolvConf = lib.mkForce false;
    };

    services.resolved.enable = true;


    };
  };
  };
}
