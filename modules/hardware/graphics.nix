{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BUNDLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bundles are groups of nix-packages generally used together
# Do not customize an app here, use mle.apps module instead

{

  options.mle.bundles.graphics.enable = lib.mkOption {
    description = "Enable graphics bundle";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.bundles.graphics.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bundled applications
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      package = pkgs.mesa;
      package32 = pkgs.pkgsi686Linux.mesa;
    };

    # Keep diagnostics on the same nixpkgs revision as the graphics stack.
    environment.systemPackages = with pkgs; [
      libva-utils
      mesa-demos
      vulkan-tools
    ];

    environment.variables.MESA_SHADER_CACHE_MAX_SIZE = "12G";

  };
}
