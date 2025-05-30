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

  config = lib.mkIf config.mle.apps.vaultwarden.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    networking.firewall.allowedTCPPorts = [ 80 8080 ];

    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden;
      dbBackend = "sqlite";

      config = {
        SIGNUPS_ALLOWED = true;
        DATABASE_URL = "/var/lib/vaultwarden/db.sqlite3";
        ROCKET_PORT = 8080;
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
          locations."/" = {
            proxyPass = "http://localhost:8080";
            proxyWebsockets = true;
          };

        };
      };
    };


  };
}
