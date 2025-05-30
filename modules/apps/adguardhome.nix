{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.adguardhome.enable = lib.mkOption {
    description = "Configure adguardhome app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.adguardhome.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.resolved.enable = false;

    services.adguardhome = {
      enable = true;
      package = lib.mkDefault pkgs.adguardhome;

      # Config made on web interface overwrite the declarative config
      mutableSettings = lib.mkDefault false;

      # Needed for integrated DHCP server
      allowDHCP = lib.mkDefault false;

      # Declarative settings : NIX style > YAML > JSON
      # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
      settings = {

        http = {
          address = "10.22.0.0:80"; # change here IP range
        };

        dns = {
          bind_hosts = [ "0.0.0.0" ];
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];
          upstream_dns = [
            "https://dns10.quad9.net/dns-query"
          ];
        };

        trusted_proxies = [
          "127.0.0.0/8"
          "::1/128"
        ];

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = lib.mkDefault false;
          safe_search.enabled = lib.mkDefault false;
        };

        filters = builtins.map(url: { enabled = true; url = url; }) [
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
        ];

      };


    };

 


  };
}
