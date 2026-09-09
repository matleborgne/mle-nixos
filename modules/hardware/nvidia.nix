{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

  options.mle.hardware.nvidia.enable = lib.mkOption {
    description = "Configure NVIDIA GPU";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.hardware.nvidia.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.core.graphics.enable = true;

  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Module configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    hardware.nvidia = {
      open = true;                         # meilleures perfs sur GPU récents
      modesetting.enable = true;           # KMS, fortement recommandé
      nvidiaSettings = true;               # panneau de configuration nvidia
      powerManagement.enable = true;       # attention aux pbs de suspend
      powerManagement.finegrained = false; # trop récent

      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
      
    hardware.graphics = {
      extraPackages = with pkgs; [
        #vaapiVdpau
        libva-vdpau-driver
      ];
    };

    # A date, NixOS continue d'utiliser xserver pour nvidia
    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };

    # TODO : à placer dans un module gaming spécifique
    environment.variables = {
      __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    };


    boot.kernelParams = [
      "module_blacklist=amdgpu,i915"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "NVreg_TemporaryFilePath=/var/tmp"
    ];
    

    
    hardware.nvidia = {
      modesetting.enable = true;

      # Driver version : stable, beta, production (older), vulkan_beta, legacy_... (check nixpkgs website)
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      # Enable the Nvidia settings menu, accessible via `nvidia-settings`
      nvidiaSettings = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = true;

# TODO : correct that part with cfg.
#      prime = {
#        intelBusId = lib.optionalAttrs (cfg.intelBusId != null) cfg.intelBusId;
#        nvidiaBusId = lib.optionalAttrs (cfg.nvidiaBusId != null) cfg.nvidiaBusId;
#        amdgpuBusId = lib.optionalAttrs (cfg.amdgpuBusId != null) cfg.amdgpuBusId;
#      };

    };

  };  
}



