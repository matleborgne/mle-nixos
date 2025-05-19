{ lib, config, pkgs, system ? builtins.currentSystem, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.fluent-gtk-theme.enable = lib.mkOption {
    description = "Configure FLUENT-GTK-THEME app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.fluent-gtk-theme.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #environment.systemPackages = with pkgs; [
    #  (builtins.getFlake "github:matleborgne/Fluent-gtk-theme/ac0794dcf9e5847fab9263a3b6123e3438863dfa").packages.x86_64-linux.default
    #];

    environment.systemPackages = with pkgs; [
      (fluent-gtk-theme.override {
        themeVariants = [ "default" ];
        colorVariants = [ "dark" ];
        sizeVariants = [ "standard" ];
        tweaks = [ "solid" "square" "round" "--icon default" ];
      })
    ];

  };

}
