{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)

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

    mle.core.graphics.enable = true;
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Module configuration
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

    # High Performance Software => au niveau du soft directement, s'il exige ROCM dans /opt/rocm
    #systemd.tmpfiles.rules = [
    #  "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    #];


  }; 
}
