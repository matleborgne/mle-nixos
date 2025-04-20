{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.docker.enable = lib.mkOption {
    description = "Configure DOCKER";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.docker.enable {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    virtualisation =  {
      containers.enable = true;
      oci-containers.backend = "docker";
      
      docker = {
        enable = true;
        autoPrune.enable = true;
        #rootless = {
        #  enable = true;
        #  setSocketVariable = true;
        #};
      };
    };
  
    users.groups.docker = {
      name = "docker";
    };
  
    # Add 'newuidmap' and 'sh' to the PATH for users' Systemd units. 
    # Required for Rootless docker.
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
    '';

  };  
}
