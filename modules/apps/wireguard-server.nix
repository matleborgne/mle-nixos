{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.wireguard-server.enable = lib.mkOption {
    description = "Configure wireguard-server app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.wireguard-server.enable (

    let
      interface = "eth0";

      # No need to touch this
      wgFwMark = 4242;
      wgTable = 4000;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Recursive activation of other mle.<modules>
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Activation and customization of APP
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];


      services.resolved.enable = true;
      networking.useNetworkd = true;

      systemd.network = {
        enable = true;

        #-----
        netdevs."15-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1420";
          };

          wireguardConfig = {
            PrivateKeyFile = "/var/lib/wireguard/server-private-key";
            FirewallMark = wgFwMark;
            RouteTable = "off";
          };

          wireguardPeers = [{
            wireguardPeerConfig = lib.mkDefault { 
              PublicKey = "PublicKeyHere";
              PresharedKeyFile = "/var/lib/wireguard/preshared-key";
              Endpoint = "wg.example.com:51820";
              AllowedIPs = [ "0.0.0.0/0" "::/0" ];
              PersistentKeepalive = 25;
              RouteTable = "off";
            };
          }];
        };

        #-----
        networks."15-wg0" = {
          matchConfig.Name = "wg0";
          address = [ "10.44.0.1/32" ];
          networkConfig = {
            # DNS = "1.1.1.1";
          };

          routingPolicyRules = [
            {
              routingPolicyRuleConfig = {
                Family = "both";
                Table = "main";
                SuppressPrefixLength = 0;
                Priority = 10;
              };
            }
            {
              routingPolicyRuleConfig = {
                Family = "both";
                InvertRule = true;
                FirewallMark = wgFwMark;
                Table = wgTable;
                Priority = 11;
              };
            }
          ];








    
  });
}
