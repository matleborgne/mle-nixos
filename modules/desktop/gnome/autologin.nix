{ config, lib, pkgs, ... }:

{

  options.mle.desktop.gnome.autologin.enable = lib.mkOption {
    description = "GNOME autologin";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.gnome.autologin.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Module
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.xserver.displayManager.gdm.autoLogin = {
      enable = true;
      inherit user;
    };

  };
}
