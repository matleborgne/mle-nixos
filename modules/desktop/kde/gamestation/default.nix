{ config, lib, pkgs, ... }:

{

  options.mle.desktop.kde.gamestation.enable = lib.mkOption {
    description = "KDE gamestation conf";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.desktop.kde.gamestation.enable (


  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle = {      
      desktop.kde = {
        default.enable = true;
      };
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Module
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.xserver.displayManager.gdm.autoLogin = {
      enable = true;
      inherit user;
    };

  });
}
