{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.wireguard.proton-client.enable = lib.mkOption {
    description = "Configure wireguard.proton-client app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.wireguard.proton-client.enable {

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
        enable = true;
        allowedTCPPorts = [ 51820 ];
        allowedUDPPorts = [ 51820 ];
      };

      systemd.services.wg-quick-up = {
        enable = true;
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/wg-quick up proton0";
          ExecStop = "/run/current-system/sw/bin/wg-quick down proton0";
        };
      };

    
  };
}
