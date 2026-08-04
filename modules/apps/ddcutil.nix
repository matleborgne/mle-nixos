{ lib, config, pkgs, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.ddcutil.enable = lib.mkOption {
    description = "Configure ddcutil backlight app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.ddcutil.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      ddcutil ddcui
    ];

     systemd.services."ddcutil" = {
          description = "Change backlight with custom values";      
          enable = true;
          after = [ "network.target" ];
    
          serviceConfig = {
            Type = "forking";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "custom-brightness" ''
              ${pkgs.ddcutil}/bin/ddcutil --display 1 setvcp 10 15
              ${pkgs.ddcutil}/bin/ddcutil --display 2 setvcp 10 60
            '';
          };
        };


  });
}
