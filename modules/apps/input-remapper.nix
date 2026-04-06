{ lib, config, inputs, pkgs, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.input-remapper.enable = lib.mkOption {
    description = "Configure input-remapper-unstable";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.input-remapper.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  # this allows you to access `pkgsUnstable` anywhere in your config
  #_module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
  #  inherit (pkgs.stdenv.hostPlatform) system;
  #  inherit (config.nixpkgs) config;
  #};

  environment.systemPackages = [
    pkgsUnstable.input-remapper
  ];
  

  };
}
