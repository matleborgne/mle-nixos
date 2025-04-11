{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

	options.mle.hardware.intelcpu.enable = lib.mkOption {
		description = "Configure INTEL CPU";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.hardware.intelcpu.enable {
	
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Settings for hardware piece
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  };  
}



