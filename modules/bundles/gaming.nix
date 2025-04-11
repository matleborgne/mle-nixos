{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUNDLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bundles are groups of nix-packages generally used together
# Do not customize an app here, use mle.apps module instead

{

	options.mle.bundles.gaming.enable = lib.mkOption {
		description = "Enable GAMING bundle";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.bundles.gaming.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.apps.steam.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      lutris
      goverlay mangohud
      bubblewrap

      wine-staging wine64
      vulkan-loader vulkan-headers vulkan-tools dxvk
      giflib libpng gnutls mpg123 openal v4l-utils libgpg-error
      libjpeg xorg.libXcomposite xorg.libXinerama libgcrypt
      ncurses ocl-icd libxslt libva
    ];

	};

}
