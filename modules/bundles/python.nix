{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUNDLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bundles are groups of nix-packages generally used together
# Do not customize an app here, use mle.apps module instead

{

	options.mle.bundles.python.enable = lib.mkOption {
		description = "Enable PYTHON bundle";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.bundles.python.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs.python312Packages; [

      # Python basics
      python pip pipdeptree

      # Jupyter basics
      ipykernel notebook
      pandas numpy
      matplotlib seaborn plotly
      openpyxl xlrd
       
      # Advanced data analysis
      chardet levenshtein jellyfish
      statsmodels
      pytesseract opencv4

      # Graphical python libraries
      flake8 pygobject3
      
    ];

	};

}
