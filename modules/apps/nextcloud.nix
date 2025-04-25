{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.nextcloud.enable = lib.mkOption {
    description = "Configure nextcloud app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.nextcloud.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # /!\ Specifications for Nextcloud APP :
    # For first installation, to not being stuck without account :

    # Enter nixos container : nixos-container root-login nextcloud
    # Re-enable root account : nextcloud-occ user:enable root
    # This is not needed if an account already exist (backup, etc.)

    # Other option : create admin user via commandline
    # nextcloud-occ user:add utilisateur
    # nextcloud-occ group:adduser admin utilisateur


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    networking.firewall = {
      allowedTCPPorts = [ 80 8080 ];
    };


    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = "localhost";
      settings = lib.mkDefault { trusted_domains = []; };

      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        adminpassFile = lib.mkDefault "/etc/nextcloud-admin-passfile";
      };

      https = true;
    };

    services.nginx = {
      enable = true;
  
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        "nextcloud.example.com" = {
          http2 = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:80/";
            proxyWebsockets = true;
          };
        };
      };

};


    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [{
        name = "nextcloud";
        ensureDBOwnership = true;
      }];
    };

    services.postgresqlBackup = {
      enable = true;
      location = "/var/lib/postgresql/backup";
      databases = [ "nextcloud" ];
      startAt = "*-*-* 03:15:00";
    };



    systemd.services = {

      "nextcloud-setup" = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
      };

      "disable-root" = {
        enable = true;
        wantedBy = [ "default.target" ];
        requires = [ "nextcloud-setup.service" ];
        after = [ "nextcloud-setup.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''/run/current-system/sw/bin/nextcloud-occ user:disable root'';
        };
      };

    };


  };
}
