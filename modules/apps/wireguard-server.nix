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

  config = lib.mkIf config.mle.apps.wireguard-server.enable {

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
        externalInterface = lib.mkDefault "eth0";
        internalInterfaces = [ "wg0" ];


      # Change random defaults set here with secret configuration
      networking.wireguard.interfaces = {

        wg0 = {
          privateKey = lib.mkDefault "ServerPrivateKeyHere";
          ips = lib.mkDefault [ "10.44.0.1/24" ]; # internal IPs on wg0
          listenPort = lib.mkDefault 53800;

          postSetup = ''
            ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
          '';

          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
          '';
    
  };
}
