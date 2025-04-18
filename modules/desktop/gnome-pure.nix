{ config, lib, pkgs, ... }:

{

	options.mle.desktop.gnome-pure.enable = lib.mkOption {
		description = "Enable GNOME";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.desktop.gnome-pure.enable {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.apps.logitech.enable = true;

    mle.desktop.codecs.enable = true;
    mle.desktop.pipewire.enable = true;

    mle.misc.networkmanager.enable = true;


		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation de GNOME
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
		# Paquets exclus de l'installation de GNOME
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
    # Packages supplémentaires à l'environnement de bureau
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
    

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # FIX de la mise en veille de GNOME
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    systemd = {
    
      services."gnome-suspend" = {
        description = "suspend gnome shell";
        before = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "nvidia-suspend.service"
          "nvidia-hibernate.service"
        ];
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''${pkgs.procps}/bin/pkill -f -STOP ${pkgs.gnome-shell}/bin/gnome-shell'';
        };
      };
    
      services."gnome-resume" = {
        description = "resume gnome shell";
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "nvidia-resume.service"
        ];
        wantedBy = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''${pkgs.procps}/bin/pkill -f -CONT ${pkgs.gnome-shell}/bin/gnome-shell'';
        };
      };

    };

# TODO : A DEPLACER

#  services.libinput.enable = true;
#  services.packagekit.enable = false;
#  services.flatpak.enable = true;
#  services.blueman.enable = true;
#  programs.fuse.userAllowOther = true;

	};

}
