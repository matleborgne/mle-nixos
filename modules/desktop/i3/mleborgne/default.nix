{ inputs, config, lib, pkgs, ... }:

{

  options.mle.desktop.i3.mleborgne.enable = lib.mkOption {
    description = "mleborgne customized i3";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.desktop.i3.mleborgne.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle = {
      
      desktop.i3 = {
        default.enable = true;
      };
      hardware.printing.enable = true;
    };

    environment.systemPackages = with pkgs; [
      libinput libinput-gestures wmctrl
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Hyprland configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Other basics configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



  };
}
