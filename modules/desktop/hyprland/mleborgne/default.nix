{ inputs, config, lib, pkgs, ... }:

{

  options.mle.desktop.hyprland.mleborgne.enable = lib.mkOption {
    description = "mleborgne customized hyprland via GSETTINGS";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.desktop.hyprland.mleborgne.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle = {
      
      desktop.hyprland = {
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

    home-manager.users.mleborgne.wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      #nvidiaPatches = true;

      extraConfig = builtins.readFile ./hyprland.conf;
      settings = {
        "$mod" = "SUPER";
      };
                 
      plugins = [
        inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
        #"/absolute/path/to/plugin.so"
      ];
      
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Other basics configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    home-manager.users.mleborgne.home.file = {

      ".local/share/rofi/themes/rofi.rasi" = {
        enable = true;
        text = builtins.readFile ./rofi.rasi;
      };

    };


  };
}
