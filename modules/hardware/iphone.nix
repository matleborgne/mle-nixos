{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself

{

  options.mle.hardware.iphone.enable = lib.mkOption {
    description = "Configure iphone filesystem";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.hardware.iphone.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation of kernel module for Realtek
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    services.usbmuxd.enable = true;

    environment.systemPackages = with pkgs; [
      libheif
      libimobiledevice
      ifuse # optional, to mount using 'ifuse ~/iphone'
    ];

  };  
}


