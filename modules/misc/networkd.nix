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
  
  config = lib.mkIf config.mle.misc.networkd.enable (

  let
    iface = (lib.removeSuffix "\n" (builtins.readFile ../../secrets/keys/netIface));

  in
  {
    
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
        "40-mv-${iface}" = {
          matchConfig.Name = "mv-${iface}";
          networkConfig.DHCP = "yes";
          dhcpV4Config.ClientIdentifier = "mac";
        };
      };
    };

  });
}
