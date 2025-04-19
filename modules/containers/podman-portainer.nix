{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.podman.portainer.enable = lib.mkOption {
    description = "Configure portainer podman container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.podman.portainer.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Services and customization of CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    virtualisation.oci-containers.containers = {

      portainer = {
        autoStart = true;
        image = "portainer/portainer-ce:latest";
        environment = {};

        ports = [
          "8000:8000"
          "9000:9000"
        ];

        extraOptions = [
          "--systemd=always"
          "--ip=10.22.0.165"
        ];

      };
    };
          
  };
}
