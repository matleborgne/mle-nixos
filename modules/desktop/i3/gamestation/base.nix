{ inputs, config, lib, pkgs, ... }:

{

  options.mle.desktop.i3.gamestation.enable = lib.mkOption {
    description = "gamestation customized i3";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.desktop.i3.gamestation.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle = {
      
      desktop.i3 = {
        base.enable = true;
      };
      hardware.printing.enable = true;
    };

    environment.systemPackages = with pkgs; [
      libinput libinput-gestures wmctrl
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # i3 autologin
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.xserver.displayManager.lightdm.extraSeatDefaults = ''
      autologin-user = gamestation
    '';

  };
}
