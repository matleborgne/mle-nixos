{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CORE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{

  options.mle.core.kernel.enable = lib.mkOption {
    description = "Enable kernel customizations";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.core.kernel.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Core settings
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    nixpkgs.overlays = [
      (_self: super: {
        linuxPackages = super.linuxPackages // {
          kernel = super.linuxPackages.kernel.override {
            structuredExtraConfig = with lib.kernel; {
              HZ_1000 = yes;
              HZ = 1000;
              PREEMPT_FULL = yes;
              IOSCHED_BFQ = yes;
              V4L2_LOOPBACK = module;
              HID = yes;
            };
          };
        };
      })
    ];

    boot = {
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false;
      kernelParams = [ "quiet" "nosplit_lock_mitigate" ];

      kernel.sysctl = {
        "kernel.split_lock_mitigate" = 0;
        "vm.swappiness" = 60;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.max_map_count" = 16777216;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.page-cluster" = 0;
        "kernel.nmi_watchdog" = 0;
        "kernel.unprivileged_userns_clone" = 1;
        "kernel.printk" = "3 3 3 3";
        "kernel.kptr_restrict" = 2;
        "kernel.kexec_load_disabled" = 1;
      };
    };

  };
}
