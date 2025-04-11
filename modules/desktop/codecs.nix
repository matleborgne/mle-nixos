{ config, lib, pkgs, ... }:

{

	options.mle.desktop.codecs.enable = lib.mkOption {
		description = "Enable codecs sound";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.desktop.codecs.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation des services
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    environment.systemPackages = with pkgs; [
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly

      mesa driversi686Linux.mesa
      ffmpeg
    ];

	};

}
