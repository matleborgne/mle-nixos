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



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #nixpkgs.config.allowUnfree = lib.mkForce true;

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      hostName = "localhost";
      settings = lib.mkDefault { trusted_domains = [] };

      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        adminpassFile = lib.mkDefault "/etc/nextcloud-admin-passfile";
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
