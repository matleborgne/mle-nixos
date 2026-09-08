{ lib, config, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.openrgb.enable = lib.mkOption {
    description = "Configure openrgb app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.openrgb.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot.kernelModules = [ "i2c-dev" ];
    boot.kernelParams = [ "acpi_enforce_resources=lax" ];

    services.hardware.openrgb = { 
      enable = true; 
      package = pkgsUnstable.openrgb;
      motherboard = "amd"; 
    };

    environment.systemPackages = with pkgsUnstable; [
      i2c-tools
    ];

    hardware.i2c = {
      group = "i2c";
      enable = true;
    };
        
  };
}
