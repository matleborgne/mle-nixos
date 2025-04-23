{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.wireguard-networkd.enable = lib.mkOption {
    description = "Configure wireguard-networkd nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.wireguard-networkd.enable (

    let
      name = "wireguard-networkd";
      net = (import ../../../secrets/keys/netIface);
      address = [ "10.22.0.154/24" ]; # change this accord to desired local IP

    in {

      containers.${name} = {

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Container structure
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = net.ifaceList;

        bindMounts = {
          "/etc/nixos/build/secrets/keys/wireguard" = { hostPath = "/etc/nixos/build/secrets/keys/wireguard"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

          imports = [
            ../../apps/wireguard/networkd-server.nix
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          mle = {
            apps = {
              wireguard.networkd-server.enable = true;
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


          # Wireguard config keys
          systemd.network = {
            netdevs."15-wg0" = {
              wireguardConfig = {
                PrivateKeyFile = "../../secrets/keys/wireguard/server-private-key";
              };

              wireguardPeers = [{
                PublicKey = builtins.readFile ../../secrets/keys/wireguard/client-public-key;
                PresharedKeyFile = "../../secrets/keys/wireguard/preshared-key";
                Endpoint = builtins.readFile ../../secrets/keys/wireguard/endpoint;
              }];
            };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        };
      };
  });
}
