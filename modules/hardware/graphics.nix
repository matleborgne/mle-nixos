{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

  options.mle.hardware.graphics.enable = lib.mkOption {
    description = "Enable graphics hardware";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.hardware.graphics.enable {
    
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
