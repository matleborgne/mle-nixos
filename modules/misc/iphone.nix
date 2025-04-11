{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

	options.mle.iphone.enable = lib.mkOption {
		description = "Configure client IPHONE connection";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.iphone.enable {
	
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
		services.usbmuxd.enable = true;

		environment.systemPackages = with pkgs; [
			libheif
			libimobiledevice
			ifuse # optional, to mount using 'ifuse /home/mleborgne/iphone'
		];

  };  
}



