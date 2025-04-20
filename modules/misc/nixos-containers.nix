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
  
  config = lib.mkIf config.mle.misc.nixos-containers.enable {
  
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


    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-+"];   # "ve-*" if using nftables instead of iptables
      externalInterface = "br0";    
      # TODO read the interface name # ip link | grep enp | awk -F ": " '{ print $2 }'
    };
  
  };  
}
