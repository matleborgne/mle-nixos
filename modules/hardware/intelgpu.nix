{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

  options.mle.hardware.intelgpu.enable = lib.mkOption {
    description = "Configure INTEL GPU";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.hardware.intelgpu.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.core.graphics.enable = true;
  
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Module configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    hardware.graphics = {
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        intel-vaapi-driver
      ];
    };

    environment.systemPackages = with pkgs; [
      intel-gpu-tools
      clinfo
    ];

    environment.variables = {
      LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
    };
    
  };  
}



