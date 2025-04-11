{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

	options.mle.hardware.bluetooth.enable = lib.mkOption {
		description = "Configure bluetooth service";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.hardware.bluetooth.enable {
	
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Settings for hardware piece
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    hardware.bluetooth = {
      enable = true;
    };
    
  };  
}



