{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.looking-glass.enable = lib.mkOption {
    description = "Configure looking-glass";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.looking-glass.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot.initrd.kernelModules = [ 
      "ivshmem"
    ];

    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

  };  
}
