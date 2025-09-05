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
      desktop.gnome.default.enable = true;
      desktop.hibernation.enable = true;
      hardware.printing.enable = true;
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Paramètres graphiques généraux - hors GSETTINGS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    environment.systemPackages = with pkgs; [
        adw-gtk3
        papirus-icon-theme
        ubuntu_font_family
    ];
    
    fonts = {
      packages = with pkgs; [
      ubuntu_font_family
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
      profiles.user.databases = [

        {
          settings = {          
            
            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            # Session GNOME
            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            # Mode nuit - éclairage lumière bleue
              "org/gnome/settings-daemon/plugins/color" = {
                night-light-enabled = true;
                night-light-temperature = lib.gvariant.mkUint32 4700;          
                night-light-schedule-to = lib.gvariant.mkDouble 3.9999;
                night-light-schedule-from = lib.gvariant.mkDouble 4.00;
                night-light-schedule-automatic = false;
              };


            # Raccourcis
            "org/gnome/desktop/wm/keybindings" = {
              move-to-workspace-left = ["<Alt><Shift>Left"];
              move-to-workspace-right = ["<Alt><Shift>Right"];
              switch-to-workspace-left = ["<Alt>Left"];
              switch-to-workspace-right = ["<Alt>Right"];
            };


            # Polices et taille d'interface
            "org/gnome/desktop/interface" = {
              text-scaling-factor = lib.gvariant.mkDouble 1.3;
              clock-show-weekday = true;
              font-name = "Ubuntu Regular 11";
              document-font-name = "Ubuntu Regular 11";
              monospace-font-name = "Ubuntu Mono Regular 12";
              gtk-theme = "adw-gtk3";
              icon-theme = "Papirus";
            }; 

            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,close";
              theme = "adw-gtk3";
              titlebar-font = "Ubuntu Bold 11";
              focus-mode = "click";
            };


            # Mutter / session
            "org/gnome/mutter" = {
                check-alive-timeout = lib.gvariant.mkUint32 30000;
              dynamic-workspaces = true;
              edge-tiling = true;
              workspaces-only-on-primary = true;
            };

            "org/gnome/desktop/session" = {
              idle-delay = lib.gvariant.mkUint32 0;
            };

            "org/gnome/desktop/background" = {
              color-shading-type = "solid";
              picture-options = "zoom";
              picture-uri = "file:////home/mleborgne/Documents/mleborgne/Logiciel/linux/graphics/wallpapers/pluto-2025.jpg";
              picture-uri-dark = "file:////home/mleborgne/Documents/mleborgne/Logiciel/linux/graphics/wallpapers/pluto-2025.jpg";         
            };

            "org/gnome/terminal/legacy" = {
              theme-variant = "dark";
            };
            
            
            # Mouse and touchpad
            "org/gnome/desktop/peripherals/touchpad" = {
                click-method = "areas";
              tap-to-click = true;
              two-finger-scrolling-enabled = true;
              speed = .25;
            };

            "org/gnome/desktop/peripherals/mouse" = {
              speed = .25;
            };


            # Veille
            "org/gnome/settings-daemon/plugins/power" = {
              sleep-inactive-battery-type = "nothing";
              sleep-inactive-ac-type = "nothing";
            };


            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            # Applications génériques
            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            # Nautilus
            "org/gnome/nautilus/preferences" = {
              show-hidden-files = true;
              show-delete-permanently = true;
              show-create-link = true;
              default-folder-viewer = "list-view";
            };

            "org/gnome/nautilus/list-view" = {
              default-zoom-level = "small";
              default-visible-columns = "['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'starred']";
            };

            "org/gtk/Settings/FileChooser" = {
              show-hidden = true;
              sort-directories-first = true;
            };


            # Epiphany
            "org/gnome/Epiphany/web" = {
              enable-webextensions = true;
            };


            # TextEditor
            "org/gnome/TextEditor" = {
              restore-session = false;
              show-line-numbers = true;
              discover-settings = false;
            };

            # Scanner
            "org/gnome/SimpleScan" = {
              jpeg-quality = lib.gvariant.mkUint32 23;
            };


            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            # Extensions GNOME
            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            # Activation des extensions
            "org/gnome/shell" = {
              disable-user-extensions = false;
              disabled-extensions = "disabled";
              enabled-extensions = [
                "pop-shell@system76.com"
                #"forge@jmmaranan.com"
                "user-theme@gnome-shell-extensions.gcampax.github.com"
                "appindicatorsupport@rgcjonas.gmail.com"
                "dash-to-panel@jderose9.github.com"
                "just-perfection-desktop@just-perfection"
                "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
                "Vitals@CoreCoding.com"
              ];
            };


            # Just perfection
            "org/gnome/shell/extensions/just-perfection" = {
              #animation = 4;
              search = false;
            };


            # User theme (TODO: mettre dans le module correspondant Fluent-round-dark)
            "org/gnome/shell/extensions/user-theme" = {
              name = "Fluent-round-Dark";
            };


    #        # Forge
    #        "org/gnome/shell/extensions/forge" = {
    #          window-gap-size = lib.gvariant.mkUint32 7;
    #          focus-border-toggle = false;
    #          move-pointer-focus-enabled = false;
    #        };

            # Pop shell
            "org/gnome/shell/extensions/pop-shell" = {
              tile-by-default = true;
              gap-inner = lib.gvariant.mkUint32 4;
              gap-outer = lib.gvariant.mkUint32 4;
            };


            # Vitals
            "org/gnome/shell/extensions/vitals" = {
              update-time = lib.gvariant.mkInt32 3;
              hide-icons = true;
              fixed-widths = true;
              show-system = false;
              show-fan = false;
              show-voltage = false;
              show-network = false;
              show-storage = false;
              show-battery = true;
              battery-slot = lib.gvariant.mkInt32 1;
            };


            # Appindicator
            "org/gnome/shell/extensions/appindicator" = {
              tray-pos = "center";
              icon-brightness = -0.3;
            };

          
            # Dash to panel
            "org/gnome/shell/extensions/dash-to-panel" = {
              dot-style-focused = "DASHES";
              dot-style-unfocused = "DOTS";
              dot-position = "TOP";
              focus-highlight-opacity = lib.gvariant.mkInt32 15;
              panel-sizes = ''{"0":40,"1":40}'';
              panel-positions = ''{"0":"TOP","1":"TOP"}'';
              stockgs-keep-dash = true;
              trans-panel-opacity = 0.0;
              trans-use-custom-opacity = true;
              animate-appicon-hover = false;
              appicon-padding = lib.gvariant.mkInt32 4;
              appicon-margin = lib.gvariant.mkInt32 1;
              show-favorites = false;
              show-activities-button = false;
              tray-size = lib.gvariant.mkInt32 20;
              status-icon-padding = lib.gvariant.mkInt32 4;
              panel-element-positions = ''{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"dateMenu","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"dateMenu","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}'';
            };

          
          };
        }

      ];
    };

# TODO
#    etc = {
#      "wallpapers/space.jpg".source = ../../assets/wallpaper/space.jpg;
#    };

  };

}
