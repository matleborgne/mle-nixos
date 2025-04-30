{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.scrutiny.enable = lib.mkOption {
    description = "Configure scrutiny app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.scrutiny.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#    networking.firewall = {
#      allowedTCPPorts = [ 80 8080 ];
#    };

    services.scrutiny = {
      enable = true;
      openFirewall = true;
    };



  };
}
