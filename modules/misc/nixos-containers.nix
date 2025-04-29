{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.nixos-containers.enable = lib.mkOption {
    description = "Configure nixos-containers";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.nixos-containers.enable (

    let
      iface = (import ../../secrets/keys/netIface).iface;

    in {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.misc.networkmanager.enable = lib.mkForce false;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# TODO test if needed for nspawn systemd nixos-containers
    virtualisation =  {
      containers.enable = true;
    };

    systemd.network = {
      enable = true;
      wait-online.enable = lib.mkForce false;
      networks = {
        "40-${iface}" = {
          matchConfig.Name = iface;
          networkConfig.DHCP = "yes";
        };
      };
    };

    networking = {
      useNetworkd = true;
      #nameservers = [
      #  "1.1.1.1"
      #  "1.0.0.1"
      #];
    };

  };  
}
