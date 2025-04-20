{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.corsair.enable = lib.mkOption {
    description = "Configure CORSAIR fans with openlinkhub";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.corsair.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      openlinkhub
      openrgb-with-all-plugins
    ];

    systemd.services.OpenLinkHub = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "sleep.target" ];
      serviceConfig = {
        WorkingDirectory = "/root/OpenLinkHub";
        #User = "openlinkhub";
        #Group = "openlinkhub";
        #Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/OpenLinkHub";
        ExecReload = "/run/current-system/sw/bin/kill -s HUP $MAINPID";
      };        
    };

    systemd.services.StopOpenLinkHub = {
      enable = true;
      wantedBy = [ "final.target" ];
      after = [ "final.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/systemctl stop OpenLinkHub.service";
      };
    };

  };  
}



