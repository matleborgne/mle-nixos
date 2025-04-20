{ config, lib, pkgs, ... }:
   
# TODO : A DEPLACER

#  services.libinput.enable = true;
#  services.packagekit.enable = false;
#  services.flatpak.enable = true;
#  services.blueman.enable = true;
#  programs.fuse.userAllowOther = true;

{

  options.mle.desktop.gnome.default.enable = lib.mkOption {
    description = "Enable GNOME";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.gnome.default.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.apps.logitech.enable = true;

    mle.desktop.codecs.enable = true;
    mle.desktop.pipewire.enable = true;

    mle.misc.networkmanager.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Base of GNOME desktop
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    services = {
      udev.packages = [ pkgs.gnome-settings-daemon ];

      xserver = {
        excludePackages = [ pkgs.xterm ];
        xkb = {
          layout = "fr";
          variant = "azerty";
          options = "eurosign:e";
        };

        displayManager.gdm.enable = true;
        desktopManager.gnome = {
          enable = true;
          extraGSettingsOverridePackages = [ pkgs.mutter ];
          extraGSettingsOverrides = ''
            [org.gnome.mutter]
            experimental-features=['scale-monitor-framebuffer']
          '';

        };
      };
    };
          

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Packages exclusion
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.gnome.excludePackages = with pkgs; [
      yelp totem tali iagno hitori atomix geary xterm
      epiphany packagekit system-config-printer
  
      gnome-backgrounds gnome-weather
      gnome-music gnome-tour gnome-photos gnome-characters
      gnome-maps gnome-clocks gnome-connections
      gnome-font-viewer gnome-software
      gnome-packagekit gnome-tour
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Added packages
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

    environment.systemPackages = with pkgs; [
      # Extensions
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.gsconnect
      gnomeExtensions.just-perfection
      gnomeExtensions.pop-shell
      gnomeExtensions.vitals
      gnomeExtensions.user-themes

      # General use
      dconf-editor
      dconf2nix
      easyeffects
      ffmpegthumbnailer
      gnome-terminal
      gnome-tweaks
      gparted	
    ];

  };
}
