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

    #nixpkgs.config.allowUnfree = lib.mkForce true;

    services.adguardhome = {
      enable = true;
      package = lib.mkDefault pkgs.adguardhome;

      # Manually change firewall port if change defaults
      port = lib.mkDefault 3000;
      openFirewall = lib.mkDefault true;

      # Config made on web interface overwrite the declarative config
      mutableSettings = lib.mkDefault false;

      # Needed for integrated DHCP server
      allowDHCP = lib.mkDefault false;

      # Declarative settings in secrets, import from yaml file
      settings = {

        dns = {
          upstream_dns = [
            "9.9.9.9" # dns.quad9.net
          ];
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = lib.mkDefault false;
          safe_search.enabled = lib.mkDefault false;
        };

        filters = builtins.map(url: { enabled = true; utl = url; }) [
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
        ];

      };


    };

 


  };
}
