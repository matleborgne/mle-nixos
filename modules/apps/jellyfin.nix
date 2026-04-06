{ lib, config, pkgs, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.jellyfin.enable = lib.mkOption {
    description = "Configure jellyfin app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.jellyfin.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

    config = ''
{
    "version": "2.2.0",
    "autoload": {
        "HAOBO Technology USB Composite Device": "jellyfin"
    }
}
'';

    remap = ''
[
    {
        "input_combination": [
            {
                "type": 1,
                "code": 172,
                "origin_hash": "1ddb121d78071126a3b70e5820860198"
            }
        ],
        "target_uinput": "keyboard",
        "output_symbol": "KEY_LEFTCTRL + Shift_L + J",
        "mapping_type": "key_macro"
    },
    {
        "input_combination": [
            {
                "type": 1,
                "code": 353,
                "origin_hash": "1ddb121d78071126a3b70e5820860198"
            }
        ],
        "target_uinput": "keyboard",
        "output_symbol": "KEY_ENTER",
        "name": "XF86Select",
        "mapping_type": "key_macro"
    }
]
'';

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      jellyfin-desktop
      input-remapper
    ];

    systemd.user.services.jellyfin-remap = {
      wantedBy = [ "default.target" ];
      script = ''
        mkdir -p /home/${user}/.config/input-remapper-2/presets/HAOBO\ Technology\ USB\ Composite\ Device
        echo ${remap} > /home/${user}/.config/input-remapper-2/presets/HAOBO\ Technology\ USB\ Composite\ Device/jellyfin.json
        echo ${config} > /home/${user}/.config/input-remapper-2/config.json
      '';
    };

     services.input-remapper.enable = true;

     systemd.services."input-renamer-jellyfin" = {
          description = "Change input controller for jellyfin";      
          enable = true;
          after = [ "network.target" ];
    
          serviceConfig = {
            Type = "forking";
            RemainAfterExit = true;
            ExecStart = ''
              ${pkgs.input-renamer}/bin/input-remapper-control --command autoload
            '';
          };
        };


  });
}
