{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.vaultwarden.enable = lib.mkOption {
    description = "Configure vaultwarden app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.vaultwarden.enable (

  let
    port = 8083;

  in
  {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    networking.firewall.allowedTCPPorts = [ 80 8083 ];

    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden;
      dbBackend = "sqlite";

      config = {
        SIGNUPS_ALLOWED = true;
        DATABASE_URL = "/var/lib/vaultwarden/db.sqlite3";
        #ROCKET_ADDRESS = "127.0.0.1";
        #ROCKET_PORT = 8083;
      };
    };

    services.nginx = {
      enable = true;
  
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
  
      virtualHosts = {
        "vaultwarden.example.com" = {
          http2 = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:80";
            proxyWebsockets = true;
          };

          extraConfig = ''
  
            # Forward real ip and host to Plex
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $server_addr;
            proxy_set_header Referer $server_addr;
            proxy_set_header Origin $server_addr;
  
            # Websockets
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
  
            # Buffering off send to the client as soon as the data is received from Plex.
            proxy_redirect off;
            proxy_buffering off;
          '';

        };
      };
    };


  });
}
