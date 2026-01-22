{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SERVICES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Services are systemd system- or user-wide generic configurations
# in order to allow thin-services use

{

  options.mle.services.user-fstab-mount.enable = lib.mkOption {
    description = "Configure MOUNTING AS USER service";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.services.user-fstab-mount.enable (
    
  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

  in {    
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Service configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Requirements :
    # Create your /home/$user/.mounts directory, with inside a file named 'mydir.env'

    # Containing :
    # MOUNTDIR="path_to_mount_dir"
    # ARGS="some_args"


    systemd.user.services."user-fstab-mount@" = {
      description = "Specified by i directory mount (present in FSTAB)";
      enable = true;
      after = [ "network.target" ];

      serviceConfig = {
        Type = "forking";
        RemainAfterExit = true;
        EnvironmentFile = [ "/home/${user}/.mounts/%i.env" ];
        ExecStartPre = "${pkgs.bash}/bin/bash -c 'test -d $MOUNTDIR || exit 0";
        ExecStart = "/run/current-system/sw/bin/mount $MOUNTDIR";
      };
    };
    

  });  
}

