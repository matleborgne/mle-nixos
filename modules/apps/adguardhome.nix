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
      openFirewall = lib.mkDefault true;

      # Config made on web interface overwrite the declarative config
      mutableSettings = lib.mkDefault false;

      # Declarative settings in secrets, import from yaml file
      settings = lib.mkDefault {
        http = {
          address = "127.0.0.1:3003"; # open firewall port
        };
        dns = {
          upstream_dns = [
            "9.9.9.9" # dns.quad9.net
          ];
        };
      };


    };

 


  };
}
