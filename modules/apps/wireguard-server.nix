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

      networking.firewall = {
        allowedTCPPorts = lib.mkDefault [];
        allowedUDPPorts = lib.mkDefault [];
      };

      networking.nat = {
        enable = true;
        externalInterface = interface;
        internalInterfaces = [ "wg0" ];
      };


      # Change random defaults set here with secret configuration
      networking.wireguard.interfaces = {

        wg0 = {
          privateKey = lib.mkDefault "ServerPrivateKeyHere";
          ips = lib.mkDefault [ "10.44.0.1/24" ]; # internal IPs on wg0, change this for you needs
          listenPort = lib.mkDefault 53800; # change this and port forwarding in the routeur

          postSetup = ''
            ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ${interface} -j MASQUERADE
          '';

          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ${interface} -j MASQUERADE
          '';


          # Random example - keep the structure, /32 mask, etc.
          peers = lib.mkDefault [          
            publicKey = "ClientPublicKeyHere";
            presharedKey = "EventuallyPreSharedKeyWithClient";
            allowedIPs = [ "10.44.0.2/32" ]; # change this for your needs, same subnet as "ips"
            persistentKeepalive = 25;
          ];
        };
      };  

    
  });
}
