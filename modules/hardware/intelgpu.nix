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
    # Configuration du serveur graphique
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    hardware.graphics = {
      enable = true;

      #driSupport = lib.mkDefault true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        intel-media-sdk
        vaapiVdpau
        libvdpau-va-gl
      ];

      #driSupport32Bit = lib.mkDefault true;
      extraPackages32 = with pkgs; [
        driversi686Linux.vaapiVdpau
        driversi686Linux.libvdpau-va-gl
      ];
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Sélection par défaut des services INTELGPU
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #services.xserver.videoDrivers = [ "amdgpu" ];
    #boot.initrd.kernelModules = [ "amdgpu" ];

    environment.variables = {
      LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
      VDPAU_DRIVER = lib.mkDefault "va_gl";
    };
    
  };  
}



