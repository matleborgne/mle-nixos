{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUNDLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bundles are groups of nix-packages generally used together
# Do not customize an app here, use mle.apps module instead

{

	options.mle.bundles.development.enable = lib.mkOption {
		description = "Enable DEVELOPMENT bundle";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.bundles.development.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [

      # Meson build
      mediawriter
      meson ninja

      # GTK apps build
      glib appstream-glib
      pkg-config wrapGAppsHook

      # Other building packages (bazar)
      #busybox
      gettext librsvg
      desktop-file-utils
      sassc
      ack fzf pydf

    ];

	};

}
