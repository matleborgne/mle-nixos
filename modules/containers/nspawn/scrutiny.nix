{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.scrutiny.enable = lib.mkOption {
    description = "Configure scrutiny nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.scrutiny.enable (

    let
      name = "scrutiny";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).scrutiny;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container structure
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      containers.${name} = {

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = net.ifaceList;

        bindMounts = {
          "/dev/sda" = { hostPath = "/dev/sda"; isReadOnly = true; };
          "/dev/sdb" = { hostPath = "/dev/sdb"; isReadOnly = true; };
          "/dev/sdc" = { hostPath = "/dev/sdc"; isReadOnly = true; };
          "/dev/sdd" = { hostPath = "/dev/sdd"; isReadOnly = true; };
          "/dev/sde" = { hostPath = "/dev/sde"; isReadOnly = true; };
          "/dev/sdf" = { hostPath = "/dev/sdf"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          #systemd.tmpfiles.rules = [
          #  "d /var/lib/scrutiny - - - -"
          #];

          imports = [
            ../../apps/scrutiny.nix
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps = {
              scrutiny.enable = true;
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
            };
          };


        };
      };
  });
}
