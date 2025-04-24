{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.mdadm.enable = lib.mkOption {
    description = "Enable mdadm service";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.mdadm.enable (

    let
      conf = (builtins.readFile ../../secrets/mdadm.conf);
      name = "md0";

    in
    {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot.swraid = {
      enable = true;
      mdadmConf = conf;
    };

    # Override mdmonitor to log to syslog instead of emailing or alerting
    systemd.services."mdmonitor".environment = {
      MDADM_MONITOR_ARGS = "--scan --syslog";
    };

    fileSystems."${name}" = {
      device = "/dev/${name}";
      fsType = "btrfs";
      options = [ "rw,relatime,ssd,space_cache=v2,subvol=/" ];
    };


  });
}
