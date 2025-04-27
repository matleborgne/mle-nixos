{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.wireguard.quick-server.enable = lib.mkOption {
    description = "Configure wireguard.quick-server app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.wireguard.quick-server.enable (

    let
      #serverFile = lib.mkDefault "/etc/wireguard/wg0.conf";

      # Direct reading from secret config file
      # It is working but can be improved
      # For instance, substring 0 10 only works for listenPort because 10 characters
      # Better idea : transform whole list into set
      readFile = (builtins.filter (x: x != []) (builtins.split "\n" (builtins.readFile ../../../secrets/wireguard/quick-server/wg0.conf)));
      readLine = (builtins.toString (builtins.attrValues (lib.attrsets.filterAttrs (n: v: n == "ListenPort") (builtins.groupBy (builtins.substring 0 10) readFile))));
      listenPort = lib.toInt (builtins.elemAt (builtins.split " = " readLine) 2);

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

      # Re-enable firewall in deployment and open ListenPort
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ listenPort ];
        allowedUDPPorts = [ listenPort ];
      };

      systemd.services.wg-quick-up = {
        enable = true;
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/wg-quick up wg0";
        };
      };

    
  });
}
