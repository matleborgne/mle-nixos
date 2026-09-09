{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

  options.mle.hardware.amdgpu.enable = lib.mkOption {
    description = "Configure AMD GPU";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.hardware.amdgpu.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.hardware.graphics.enable = true;
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configuration du serveur graphique
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    hardware.amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };

    hardware.graphics = {
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.hiprt
      ];
    };

    environment.systemPackages = with pkgs; [
      clinfo
      rocmPackages.rocminfo
      rocmPackages.rocm-smi
    ];

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Sélection par défaut des services AMDGPU - VULKAN - ROCM
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.xserver.videoDrivers = [ "amdgpu" ];
    boot.initrd.kernelModules = [ "amdgpu" ];

    # Force RADV (vulkan-radeon) over amdvlk - via environment variable
    environment.variables.AMD_VULKAN_ICD = lib.mkDefault "RADV";

    # High Performance Software
    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
    
  };  
}



