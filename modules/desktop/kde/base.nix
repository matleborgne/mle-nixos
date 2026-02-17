{ config, lib, pkgs, ... }:

{

  options.mle.desktop.kde.base.enable = lib.mkOption {
    description = "Enable KDE plasma base";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.kde.base.enable {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle = {

      apps = {
        bash.enable = true;
        fish.enable = true;
        nano.enable = true;
        logitech.enable = true;
      };

      desktop = {
        codecs.enable = true;
        pipewire.enable = true;
      };

      misc.networkmanager.enable = true;
    };


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
