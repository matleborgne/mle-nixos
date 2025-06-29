{ config, lib, pkgs, ... }:

{

  options.mle.desktop.hyprland.default.enable = lib.mkOption {
    description = "Enable hyprland";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.hyprland.default.enable {
    
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

    programs.hyprland = {
      enable = true;
    };
      
    services = {
      #udev.packages = [ pkgs.gnome-settings-daemon ];

      #xserver = {
      #  excludePackages = [ pkgs.xterm ];
      #  xkb = {
      #    layout = "fr";
      #    variant = "azerty";
      #    options = "eurosign:e";
      #  };
      #};

      displayManager.sddm.enable = true;
      
      #desktopManager.gnome = {
      #  enable = true;
      #  extraGSettingsOverridePackages = [ pkgs.mutter ];
      #  extraGSettingsOverrides = ''
      #    [org.gnome.mutter]
      #    experimental-features=['scale-monitor-framebuffer']
      #  '';
      #};
      
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Added packages
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #programs.kdeconnect = {
    #  enable = true;
    #  package = pkgs.gnomeExtensions.gsconnect;
    #};

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      # Extensions

      # General use
      kitty
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
