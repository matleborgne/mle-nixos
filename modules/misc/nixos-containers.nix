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
      vlans = [ 1 ];
    };

    networking.macvlans.mv-eth1-host = {
      interface = "eth1";
      mode = "bridge";
    };

    networking.interfaces.eth1.ipv4.addresses = lib.mkForce [];
    networking.interfaces.mv-eth1-host = {
      ipv4.addresses = [ { address = "10.22.0.1"; prefixLength = 24; } ];
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

#    networking.nat = {
#      enable = true;
#      internalInterfaces = ["ve-+"];   # "ve-*" if using nftables instead of iptables
#      externalInterface = "enp3s0";    
#      # TODO read the interface name # ip link | grep enp | awk -F ": " '{ print $2 }'
#    };

#    networking = {
#      useNetworkd = true;
#      useDHCP = true;

#      bridges = {
#        br0 = { interfaces = [ "enp3s0" ]; };
#      };
      
#      interfaces.br0 = {
#        useDHCP = true;
#        ipv4.addresses = [{ address = "10.23.0.3"; prefixLength = 8; }];
#      };
    };

  };  
}
