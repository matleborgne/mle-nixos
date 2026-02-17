{ inputs, config, lib, pkgs, ... }:

{

  options.mle.desktop.i3.base.enable = lib.mkOption {
    description = "Enable i3 base";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.i3.base.enable {
    
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
    # Base of i3 desktop
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.xserver = {
      enable = true;
      windowManager.i3 = {
        enable = true;
      };
    };

    services.xserver.desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    services.xserver.displayManager = {
      lightdm.enable = true;
      defaultSession = "xfce+i3";
    };
      
    services = {
      libinput.enable = true;    
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Added packages
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      kitty
      pavucontrol
      nautilus

      adw-gtk3
      papirus-icon-theme
      ubuntu-classic
    ];

    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Fixing problems with themes (system-wide solution)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita";
          icon-theme = "Flat-Remix-Red-Dark";
          font-name = "Noto Sans Medium 11";
          document-font-name = "Noto Sans Medium 11";
          monospace-font-name = "Noto Sans Mono Medium 11";
        };
      }
    ];
      
    
  };
}
