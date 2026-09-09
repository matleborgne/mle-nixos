{ config, lib, pkgs, pkgsUnstable, ... }:
   
# TODO : A DEPLACER

#  services.libinput.enable = true;
#  services.packagekit.enable = false;
#  services.flatpak.enable = true;
#  services.blueman.enable = true;
#  programs.fuse.userAllowOther = true;

{

  options.mle.desktop.gnome.base.enable = lib.mkOption {
    description = "Enable GNOME base";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.gnome.base.enable {
    
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
    # Base of GNOME desktop
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    services = {
      displayManager.gdm.enable = true;

      desktopManager.gnome = {
        enable = true;
      };

      xserver.xkb = {
        layout = "fr";
        variant = "azerty";
        options = "eurosign:e";
      };
    };

     hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
     };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Packages exclusion
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.gnome.excludePackages = with pkgs; [
      yelp totem tali iagno hitori atomix geary xterm
      epiphany packagekit system-config-printer
      evince gnome-console
  
      gnome-backgrounds gnome-weather
      gnome-music gnome-tour gnome-photos gnome-characters
      gnome-maps gnome-clocks gnome-connections
      gnome-font-viewer gnome-software
      gnome-packagekit
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Added packages
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.kdeconnect = {
      enable = true;
      package = pkgs.valent;
    };

    environment.systemPackages = with pkgs; [
      # Extensions
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.just-perfection
      gnomeExtensions.vitals
      gnomeExtensions.user-themes
      gnomeExtensions.launch-new-instance
      gnomeExtensions.open-bar
      gnomeExtensions.rounded-window-corners-reborn

      # General use
      file-roller
      dconf-editor
      dconf2nix
      easyeffects
      ffmpegthumbnailer
      gnome-terminal
      gnome-tweaks
      gparted  

      # GNOME 49
      papers
      ptyxis

    ] ++ [
      pkgsUnstable.gnomeExtensions.pop-shell
    ];

  };
}
