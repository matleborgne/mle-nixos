{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.docker.portainer.enable = lib.mkOption {
    description = "Configure portainer docker container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.docker.portainer.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Services and customization of CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    virtualisation.oci-containers.containers = {

      portainer = {
        autoStart = true;
        image = "portainer/portainer-ce:latest";
        environment = {};

        ports = [];

        volumes = [];
      };
    };
          
  };
}
