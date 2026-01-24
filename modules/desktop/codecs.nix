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
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gst-vaapi

      mesa driversi686Linux.mesa
    ] ++

    [(pkgs.ffmpeg-full.override {
      withUnfree = true;
    })];

    environment.variables = {
      GST_PLUGIN_PATH = "/run/current-system/sw/lib/gstreamer-1.0/";
    };

  };
}
