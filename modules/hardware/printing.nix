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
    
    services.printing = {
      enable = true;
      startWhenNeeded = true;
      drivers = [ pkgs.brlaser ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.udev.packages = [ pkgs.sane-airscan ];
    
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
    
    users.groups = {
      scanner.members = normalUsers;
      lp.members = normalUsers;
      lpadmin.members = normalUsers;
    };


  });  
}
