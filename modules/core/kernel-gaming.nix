{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CORE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{

  options.mle.core.kernel-gaming.enable = lib.mkOption {
    description = "Enable kernel customizations";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.core.kernel-gaming.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Core settings
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot = {
      kernel.sysctl = {

        # Gaming pur
        "kernel.split_lock_mitigate" = 0;
        "vm.max_map_count" = 16777216;

        # Mémoire et écritures disque
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.page-cluster" = 0;

        # Divers
        "kernel.nmi_watchdog" = 0;
        "kernel.printk" = "3 3 3 3";
      };
    };

  };
}
