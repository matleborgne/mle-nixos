{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.cockpit.enable = lib.mkOption {
    description = "Configure COCKIT app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.cockpit.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.misc.networkmanager.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      pcp cockpit
    ];

    services.cockpit = {
      enable = true;
      openFirewall = true;
      port = 9090;

      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };
    };

    services.nginx = {
      enable = true;
  
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
  
      virtualHosts = {
        "cockpit.example.com" = {
          http2 = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9090/";
            proxyWebsockets = true;
          };
  
          extraConfig = ''
            # Required to proxy the connection to Cockpit
            proxy_pass https://127.0.0.1:9090;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Required for web sockets to function
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Pass ETag header from Cockpit to clients.
            # See: https://github.com/cockpit-project/cockpit/issues/5239
            gzip off;
          '';
        };
      };
    };   
  

  };
}
