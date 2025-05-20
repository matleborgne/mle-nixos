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

  config = lib.mkIf config.mle.apps.fluent-gtk-theme.enable (

    #let
    #  fluent-gtk-theme = pkgs.callPackage ../../pkgs/fluent-gtk-theme.nix {};

    #in
    {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      (builtins.getFlake "github:matleborgne/Fluent-gtk-theme/bba52f563f6823a6fe095bab4b945e0306a67bf8").packages.x86_64-linux.default
    ];

    #environment.systemPackages = with pkgs; [
    #  (fluent-gtk-theme.override {
    #    themeVariants = [ "default" ];
    #    colorVariants = [ "dark" ];
    #    sizeVariants = [ "standard" ];
    #    tweaks = [ "solid" "square" "round" ];
    #  })
    #];

  });
}
