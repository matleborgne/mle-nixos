{ config, lib, pkgs, ... }:

{

  options.mle.desktop.kde.default.enable = lib.mkOption {
    description = "Enable KDE plasma";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.kde.default.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.apps.logitech.enable = true;

    mle.desktop.codecs.enable = true;
    mle.desktop.pipewire.enable = true;

    mle.misc.networkmanager.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Base of KDE PLASMA desktop
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    services = {
      #udev.packages = [ pkgs.gnome-settings-daemon ];

      xserver = {
        excludePackages = [ pkgs.xterm ];
        xkb = {
          layout = "fr";
          variant = "azerty";
          options = "eurosign:e";
        };
      };

      displayManager.gdm.enable = true;

      desktopManager.plasma6 = {
        enable = true;
      };
    };

    # GNOME desktop integration
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Packages exclusion
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.plasma6.excludePackages = with pkgs; [
      
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Added packages
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.kdeconnect = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
   
    ];

  };
}
