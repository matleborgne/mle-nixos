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






    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Fixing problems with libinput gestures
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    home-manager.users.mleborgne.home.file = {
      ".config/libinput-gestures.conf" = {
        enable = true;
        text = ''
          gesture swipe right 3 hyprctl dispatch workspace +1
          gesture swipe left 3 hyprctl dispatch workspace -1
        '';
      };
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Hyprland configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    home-manager.users.mleborgne.wayland.windowManager.hyprland = {
      enable = true;
      systemdIntegration = true;
      #nvidiaPatches = true;


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Basic settings
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      settings = {
        "$mod" = "SUPER";
      };


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Direct configuration
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      extraConfig = ''

        ##############
        ### INPUTS ###
        ##############

        #----- Input -----
        input {
          kb_layout = fr
          follow_mouse = 1
          touchpad {
            natural_scroll = true
          }
          gestures {
            workspace_swipe = true
          }
          sensitivity = 0  # -1.0 - 1.0, 0 means no modification
        }


        ################
        ### PROGRAMS ###
        ################

        #----- Basic use -----
        bind = $mod, Q, exec, kitty
        bind = $mod, C, killactive,
        bind = $mod, M, exit,
        bind = $mod, V, togglefloating,
        bind = $mod, F, fullscreenstate, 3

        #----- Applications shortcuts -----
        bind = $mod, L, exec, librewolf


        #############################
        ### WINDOWS - SUPER BASED ###
        #############################

        #----- Resize active window -----
        bindm = $mod, mouse:272, resizewindow
        bind = $mod, left, resizeactive, -10 0
        bind = $mod, right, resizeactive, 10 0
        bind = $mod, up, resizeactive, 0 -10
        bind = $mod, down, resizeactive, 0 10

        #----- Move active window -----
        bindm = $mod SHIFT, mouse:272, movewindow
        bind = $mod SHIFT, left, movewindoworgroup, l
        bind = $mod SHIFT, right, movewindoworgroup, r
        bind = $mod SHIFT, up, movewindoworgroup, u
        bind = $mod SHIFT, down, movewindoworgroup, d

        #----- Change window focus -----
        bind = $mod, Tab, cyclenext,
        bind = $mod SHIFT, Tab, cyclenext, prev


        ###############################
        ### WORKSPACES - ALT BASED ###
        ###############################

        #----- Mode view through workspaces -----
        bind = ALT, mouse_down, workspace, -1
        bind = ALT, mouse_up, workspace, +1
        bind = ALT, right, workspace, +1
        bind = ALT, left, workspace, -1

        bind = ALT, code:10, workspace, 1
        bind = ALT, code:11, workspace, 2
        bind = ALT, code:12, workspace, 3
        bind = ALT, code:13, workspace, 4
        bind = ALT, code:14, workspace, 5
        bind = ALT, code:15, workspace, 6
        bind = ALT, code:16, workspace, 7
        bind = ALT, code:17, workspace, 8
        bind = ALT, code:18, workspace, 9
        bind = ALT, code:19, workspace, 10

        #----- Mode active window through workspaces -----
        bind = ALT SHIFT, mouse_down, movetoworkspace, -1
        bind = ALT SHIFT, mouse_up, movetoworkspace, +1
        bind = ALT SHIFT, right, movetoworkspace, +1
        bind = ALT SHIFT, left, movetoworkspace, -1

        bind = ALT SHIFT, code:10, movetoworkspace, 1
        bind = ALT SHIFT, code:11, movetoworkspace, 2
        bind = ALT SHIFT, code:12, movetoworkspace, 3
        bind = ALT SHIFT, code:13, movetoworkspace, 4
        bind = ALT SHIFT, code:14, movetoworkspace, 5
        bind = ALT SHIFT, code:15, movetoworkspace, 6
        bind = ALT SHIFT, code:16, movetoworkspace, 7
        bind = ALT SHIFT, code:17, movetoworkspace, 8
        bind = ALT SHIFT, code:18, movetoworkspace, 9
        bind = ALT SHIFT, code:19, movetoworkspace, 10

      '';

#            ", Print, exec, grimblast copy area"


      

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Plugins - prefered use with hyprland flake
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
      plugins = [
        inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
        #"/absolute/path/to/plugin.so"
      ];
            

    };

  };
}
