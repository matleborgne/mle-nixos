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
      # Change server address here
      wgIpv4 = "10.44.0.1";
      wgIpv6 = "10:44:0:1::";

      # No need to touch this
      wgFwMark = 4242;
      wgTable = 4000;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Recursive activation of other mle.<modules>
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.networkmanager.enable = lib.mkForce false;


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
            wireguardPeerConfig = { 
              PublicKey = (builtins.readFile /var/lib/wireguard/client-public-key);
              PresharedKeyFile = "/var/lib/wireguard/preshared-key";
              Endpoint = (builtins.readFile /var/lib/wireguard/endpoint); #like wg.example.com:51820
              AllowedIPs = [ "0.0.0.0/0" "::/0" ];
              PersistentKeepalive = 25;
              RouteTable = "off";
            };
          }];
        };

        #-----
        networks."15-wg0" = {
          matchConfig.Name = "wg0";
          linkConfig.RequiredForOnline = false;
          address = [
            "${wgIpv4}/32"
            "${wgIpv6}/128"
          ];
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

          routes = [
            {
              routeConfig = {
                Destination = "0.0.0.0/0";
                Table = wgTable;
                Scope = "link";
              };
            }
            {
              routeConfig = {
                Destination = "::/0";
                Table = wgTable;
                Scope = "link";
              };
            }
          ];
        };
      };



      networking.nftables = {
        enable = true;
        ruleset = ''
          table inet wg-wg0 {
            chain preraw {
              type filter hook prerouting priority raw; policy accept;
              iifname != "wg0" ip daddr ${wgIpv4} fib saddr type != local drop
              iifname != "wg0" ip6 daddr ${wgIpv6} fib saddr type != local drop
            }
            chain premangle {
              type filter hook prerouting priority mangle; policy accept;
              meta l4proto udp meta mark set ct mark
            }
            chain postmangle {
              type filter hook postrouting priority mangle; policy accept;
              meta l4proto udp meta mark ${toString wgFwMark} ct mark set meta mark
            }
          }
        '';
      };


    
  });
}
