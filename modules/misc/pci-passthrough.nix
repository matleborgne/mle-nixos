{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.pci-passthrough.enable = lib.mkOption {
    description = "Configure pci-passthrough";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.pci-passthrough.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot.initrd.kernelModules = [ 
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    boot.blacklistedKernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
      "nouveau"
      "nvidiafb"
      "rivafb"
    ];
    
    boot.kernelParams = [ 
      "amd_iommu=on"
      "iommu=pt"
      "pcie_acs_override=downstream,multifunction"
      "vfio-pci.ids=10de:2d05,10de:22eb" # replace with yours (lspci -nnk)
    ];


  };  
}
