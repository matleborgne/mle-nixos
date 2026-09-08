{ config, lib, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUNDLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bundles are groups of nix-packages generally used together
# Do not customize an app here, use mle.apps module instead

{

  options.mle.bundles.datapro.enable = lib.mkOption {
    description = "Enable DATAPRO bundle";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.bundles.datapro.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #mle.apps.vscode.enable = true;
    mle.bundles.python.enable = true;

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgsUnstable; [

      meld     
      sqlitebrowser
      sqlite

      signal-desktop

    ];

  };

}
