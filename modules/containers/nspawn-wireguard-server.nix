{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.nspawn.wireguard-server.enable = lib.mkOption {
    description = "Configure wireguard-server nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.nspawn.wireguard-server.enable (

    let
      address = [ "10.22.0.154/24" ]; # change this accord to desired local IP

    in {

      containers.wireguard-server = {
        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = [ "enp3s0" ];

        bindMounts = {
          "/etc/nixos/build/secrets/keys/wireguard" = { hostPath = "/etc/nixos/build/secrets/keys/wireguard"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, ... }: {

          imports = [
            ../apps/wireguard/networkd-server.nix
            ../apps/fish.nix
          ];
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Main services
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          mle = {
            apps = {
              wireguard-server.enable = true;
              fish.enable = true;
            };
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
          # Network
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          system.stateVersion = "24.11";

          boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv6.ip_forward" = 1;
          };

          networking = {
            hostName = "wireguard-server";

            useNetworkd = true;
            useDHCP = false;
            useHostResolvConf = false;
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


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Other services
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        };
      };
  });
}
