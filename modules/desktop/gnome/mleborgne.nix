{ config, lib, pkgs, ... }:

{

  options.mle.desktop.gnome.mleborgne.enable = lib.mkOption {
    description = "mleborgne customized GNOME via GSETTINGS";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.desktop.gnome.mleborgne.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle = {
      desktop.gnome.base.enable = true;
      #desktop.hibernation.enable = true;
      hardware.printing.enable = true;
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres graphiques généraux - hors GSETTINGS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    environment.systemPackages = with pkgs; [
        adw-gtk3
        papirus-icon-theme
        #ubuntu_font_family
        ubuntu-classic
    ];
    
    fonts = {
      packages = with pkgs; [
      #ubuntu_font_family deprecated
      ubuntu-classic
      #(nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
    
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Ubuntu Regular" ];
          sansSerif = [ "Ubuntu Regular" ];
          monospace = [ "Ubuntu Mono Regular" ];  
        };
      };

    };
    
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres GNOME - GSETTINGS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.dconf = {
      enable = true;
    };

# TODO
#    etc = {
#      "wallpapers/space.jpg".source = ../../assets/wallpaper/space.jpg;
#    };

  };

}
