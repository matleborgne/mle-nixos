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
    # Home-manager configuration
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
        "$ws" = "ALT";
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

        #----- Change window focus -----
        bind = $mod, left, movefocus, l
        bind = $mod, right, movefocus, r
        bind = $mod, up, movefocus, u
        bind = $mod, down, movefocus, d

        #----- Active window resize -----
        # Press SUPER + S to enter resize mode, then escape to exit mode
        bind = $mod, S, submap, resize
          submap = resize
            binde = , right, resizeactive, 10 0
            binde = , left, resizeactive, -10 0
            binde = , up, resizeactive, 0 -10
            binde = , down, resizeactive, 0 10
            bind = , escape, submap, reset
          submap = reset

        #----- Move/resize windows with mod and LMB/RMB and dragging -----
        bindm = $mod, mouse:272, movewindow
        bindm = $mod, mouse:273, resizewindow
        bindm = ALT, mouse:272, resizewindow


        ###############################
        ### WORKSPACES - ALT BASED ###
        ###############################

        #----- Mode view to workspace X -----
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

        #----- Mode active window to workspace X -----
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


#      settings = {
#        "$mod" = "SUPER";

#        bind =
#          [
#            "$mod, F, exec, firefox"
#            ", Print, exec, grimblast copy area"
#          ]
  
#          ++ (
#            # workspaces
#            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
#            builtins.concatLists (builtins.genList (i:
#                let ws = i + 1;
#                in [
#                  "$mod, code:1${toString i}, workspace, ${toString ws}"
#                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
#                ]
#              )
#              9)
#         );

#        };

      

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Plugins - prefered use with hyprland flake
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
      plugins = [
        inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
        #"/absolute/path/to/plugin.so"
      ];


            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            # Extensions GNOME
            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            

    };

  };
}
