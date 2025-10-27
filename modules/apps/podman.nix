{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.podman.enable = lib.mkOption {
    description = "Configure PODMAN environment";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.podman.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    
    virtualisation = {
      podman = {
        enable = true;
  
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;
  
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs; [
      dive # look into docker image layers
      podman-tui # status of containers in the terminal
      #docker-compose # start group of containers for dev
      podman-compose # start group of containers for dev
    ];

    
  };
}
