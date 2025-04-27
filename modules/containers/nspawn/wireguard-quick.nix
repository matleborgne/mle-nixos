{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.wireguard-quick.enable = lib.mkOption {
    description = "Configure wireguard-quick nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.wireguard-quick.enable (

    let
      name = "wireguard-quick";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).wireguard-quick;

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
          "/etc/wireguard" = { hostPath = "/etc/nixos/build/secrets/wireguard/quick-server"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = {
            inherit address;
            extraConfig = ''
              ConfigureWithoutCarrier=true
              ActivationPolicy=always-up
            '';
          };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          imports = [
            ../../apps/wireguard/quick-server.nix
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps = {
              wireguard.quick-server.enable = true;
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
            };
          };

          boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv6.ip_forward" = 1;
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        };
      };
  });
}
