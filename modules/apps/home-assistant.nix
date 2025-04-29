{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.home-assistant.enable = lib.mkOption {
    description = "Configure home-assistant app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.home-assistant.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    networking.firewall = {
      allowedTCPPorts = [ 8123 ];
    };


    services.home-assistant = {
      enable = true;

      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
      ];

      config = {
        default_config = {};
      };
    };

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    ];
  

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Reverse proxying with nginx
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
    services.home-assistant.config.http = {
      server_host = "::1";
      trusted_proxies = [ "::1" ];
      use_x_forwarded_for = true;
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."hass.example.com" = {
        #forceSSL = true;
        #enableACME = true;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123";
          proxyWebsockets = true;
        };
      };
    };


  };
}
