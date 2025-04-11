{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

	options.mle.hardware.printing.enable = lib.mkOption {
		description = "Enable priting support";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.hardware.printing.enable (
		
    let
      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;

    in
    {

		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configuration des services (cups, avahi, udev, sane)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    services = {

      # CUPS / priting daemon
      printing = {
        enable = true;
        startWhenNeeded = true;
        drivers = with pkgs; [
          brgenml1cupswrapper
          brgenml1lpr
          brlaser
          cnijfilter2
          epkowa
          gutenprint
          gutenprintBin
          hplip
          hplipWithPlugin
          samsung-unified-linux-driver
          splix
        ];
      };

      # Autodiscovery with AVAHI
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # UDEV packages
      udev.packages = with pkgs; [
        sane-airscan
        utsushi
      ];


    };

    # SANE scanner
    hardware.sane = {
      enable = true;
      extraBackends = with pkgs; [
        hplipWithPlugin
        sane-airscan
        epkowa
        utsushi
      ];
    };

    # Let users install printer manually
    programs.system-config-printer.enable = true;
    

		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configuration des groupes utilisateur
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    users.groups = {
      scanner.members = normalUsers;
      lp.members = normalUsers;
      cups.members = normalUsers;
      printer.members = normalUsers;
    };


  });  
}
