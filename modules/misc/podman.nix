{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

	options.mle.podman.enable = lib.mkOption {
		description = "Configure podman";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.podman.enable {
	
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # cockpit-podman to add here

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # lib.optional (mle.cockpit.enable = true) cockpit-podman

		environment.systemPackages = with pkgs; [
			podman
		];

  };  
}
