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

        #----- Input -----
        input {
          kb_layout = fr
          follow_mouse = 1
          touchpad { natural_scroll = true }
          sensitivity = 0  # -1.0 - 1.0, 0 means no modification
        }     

        #----- Basic use -----
        bind = $mod, Q, exec, kitty
        bind = $mod, C, exit

        #----- Active window resize -----
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
