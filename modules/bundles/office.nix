{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUNDLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bundles are groups of nix-packages generally used together
# Do not customize an app here, use mle.apps module instead

{

	options.mle.bundles.office.enable = lib.mkOption {
		description = "Enable OFFICE bundle";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.bundles.office.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      libreoffice
      freefilesync
      cherrytree

      pdfarranger
      gimp   
      drawio

      bitwarden
    ];

	};

}
