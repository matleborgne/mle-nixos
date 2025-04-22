{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.networkd.enable = lib.mkOption {
    description = "Enable networkd service";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.networkd.enable ({
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    networking = {
      useNetworkd = true;
      useDHCP = false;
      useHostResolvConf = false;
    };

    systemd.network = {
      enable = true;
      networks = {
        "40-mv-enp3s0" = {
          matchConfig.Name = "mv-enp3s0";
          networkConfig.DHCP = "yes";
          dhcpV4Config.ClientIdentifier = "mac";
        };
      };
    };

  };
}
