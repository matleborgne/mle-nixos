{ config, lib, pkgs, pkgsUnstable, ... }:

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

    mle.apps = {
      steam.enable = true;
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      goverlay mangohud
      bubblewrap

      wine-staging wine64
      vulkan-loader vulkan-headers vulkan-tools dxvk
      giflib libpng gnutls mpg123 openal v4l-utils libgpg-error
      libjpeg libxcomposite libxinerama libgcrypt
      ncurses ocl-icd libxslt libva

    ] ++ [
      pkgsUnstable.cartridges

# TEMPORARY LUTRIS FIX
      (pkgs.lutris.override {
  # Intercept buildFHSEnv to modify target packages
  buildFHSEnv = args: pkgs.buildFHSEnv (args // {
    multiPkgs = envPkgs:
      let
        # Fetch original package list
        originalPkgs = args.multiPkgs envPkgs;

        # Disable tests for openldap
        customLdap = envPkgs.openldap.overrideAttrs (_: { doCheck = false; });
      in
      # Replace broken openldap with the custom one
      builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
  });
})

    ];
  };
}
