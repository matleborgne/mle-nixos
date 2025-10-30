{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.thunderbird.enable = lib.mkOption {
    description = "Configure THUNDERBIRD app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.thunderbird.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.thunderbird = {
      enable = true;

      policies = {
        Preferences_intl.accept_languages = "fr";
        DisableTelemetry = true;
      };
      
      preferences = {
      
        # Language by default
        "intl.accept_languages" = "fr-fr,en-us,en";
        "intl.locale.requested" = "fr,en-US";      
      };        

    };


  environment.systemPackages = with pkgs; [
    #protonmail-bridge-gui
    protonmail-bridge
  ];


#    home-manager.users.${user} = {
#    
#      programs.thunderbird = {
#
#        accounts.email = ...

  };

}
