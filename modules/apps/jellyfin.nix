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

    environment.systemPackages = [
      pkgs.jellyfin-desktop
      pkgsUnstable.input-remapper
    ];

     services.input-remapper.enable = true;

   #  systemd.services."input-renamer-jellyfin" = {
   #       description = "Change input controller for jellyfin";      
   #       enable = true;
   #       after = [ "network.target" ];
   # 
   #       serviceConfig = {
   #         Type = "forking";
   #         RemainAfterExit = true;
   #         ExecStart = ''
   #           /run/current-system/sw/bin/input-remapper-control --command autoload
   #         '';
   #       };
   #     };


  });
}
