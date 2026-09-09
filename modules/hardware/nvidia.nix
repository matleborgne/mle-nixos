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

    # Required for hibernation
    boot.extraModprobeConfig = ''
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
      options nvidia NVreg_TemporaryFilePath=/var/tmp
    '';

    # A date, NixOS continue d'utiliser xserver pour nvidia
    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };

    # TODO : à placer dans un module gaming spécifique
    environment.variables = {
      __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    };

    boot.blacklistedKernelModules = [
      "nouveau"
      "nova_core"
    ];


  };  
}



