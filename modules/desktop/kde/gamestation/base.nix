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
        base.enable = true;
      };
    };

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Module
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    services.displayManager.autoLogin = {
      enable = true;
      inherit user;
    };

    # Autohide menu (methode provisoire)
    systemd.user.services.qdbus = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          /run/current-system/sw/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                      var panel = panels()[0];
                      panel.hiding = \"autohide\";
                      "
        '';
      };
    };

  });
}
