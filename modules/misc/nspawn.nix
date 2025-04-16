{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

	options.mle.misc.nspawn.enable = lib.mkOption {
		description = "Configure nspawn";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.misc.nspawn.enable {
	
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	  virtualisation =  {
	    containers.enable = true;
	    #oci-containers.backend = "docker";
    };

    networking.nat = {
  enable = true;
  # Use "ve-*" when using nftables instead of iptables
  internalInterfaces = ["ve-+"];
  externalInterface = "ens3";
  # Lazy IPv6 connectivity for the container
  enableIPv6 = true;
};

containers.nextcloud = {
  autoStart = true;
  privateNetwork = true;
  hostAddress = "10.22.0.30";
  localAddress = "10.22.0.31";
  config = { config, pkgs, lib, ... }: {

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud28;
      hostName = "localhost";
      config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
    };

    system.stateVersion = "24.11";

    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };
      # Use systemd-resolved inside the container
      # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
      useHostResolvConf = lib.mkForce false;
    };
    
    services.resolved.enable = true;

  };
};
  
  };  
}
