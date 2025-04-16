{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

	options.mle.misc.podman.enable = lib.mkOption {
		description = "Configure podman";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.misc.podman.enable {
	
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # cockpit-podman to add here

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # lib.optional (mle.apps.cockpit.enable = true) cockpit-podman
	
	  virtualisation =  {
	    containers.enable = true;
	    oci-containers.backend = "podman";
	    podman = {
	      enable = true;
	      autoPrune.enable = true;
	      # Create a `docker` alias for podman, to use it as a drop-in replacement
	      dockerCompat = true;
	      # Required for containers under podman-compose to be able to talk to each other.
	      defaultNetwork.settings.dns_enabled = true;
	    }; # podman
	
	    containers.storage.settings = {
	      storage = {
		#driver = "btrfs";
		runroot = "/run/containers/storage";
		graphroot = "/var/lib/containers/storage";
		options.overlay.mountopt = "nodev,metacopy=on";
	      }; # storage
	    };
	  }; # virtualisation
	
	  users.groups.podman = {
	    name = "podman";
	  };
	
	  environment.systemPackages = with pkgs; [
	    dive # look into docker image layers
	    podman
	    podman-tui   # Terminal mgmt UI for Podman
	    passt    # For Pasta rootless networking
	  ];
	
	  # Add 'newuidmap' and 'sh' to the PATH for users' Systemd units. 
	  # Required for Rootless podman.
	  systemd.user.extraConfig = ''
	    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
	  '';

  };  
}
