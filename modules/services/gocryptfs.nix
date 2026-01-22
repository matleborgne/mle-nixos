{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SERVICES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Services are systemd system- or user-wide generic configurations
# in order to allow thin-services use

{

  options.mle.services.gocryptfs.enable = lib.mkOption {
    description = "Configure GOCRYPTFS system-wide service";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.services.gocryptfs.enable (
    
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

    # With PASSWORD PROMPT
    systemd.services."gocryptfs@" = {
      description = "Specified by i gocryptfs mount";      
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        ConditionPathExists = "/var/uncrypt/%i";
      };

      serviceConfig = {
        Type = "forking";
        RemainAfterExit = true;
        EnvironmentFile = [ "/home/${user}/.gocryptfs/%i.env" ];
        ExecStart = "/run/current-system/sw/bin/sh -c '/run/current-system/sw/bin/systemd-ask-password Password | /run/current-system/sw/bin/gocryptfs -allow_other -config $GOCONF /var/media/nas/%i /var/uncrypt/%i'";
      };
    };

    
    # With PASSFILE
    systemd.services."gocryptfs-passfile@" = {
      description = "Specified by i gocryptfs mount with passfile";      
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        ConditionPathExists = "/var/uncrypt/%i";
      };

      serviceConfig = {
        Type = "forking";
        RemainAfterExit = true;
        EnvironmentFile = [ "/home/${user}/.gocryptfs/%i.env" ];
        ExecStart = ''
          ${pkgs.bash}/bin/bash -c \
            '${pkgs.gocryptfs}/bin/gocryptfs \
              ''${cipherdir} ''${mountdir} \
              -config ''${config} \
              -passfile ''${passfile} \
              ''${args}'
        '';

        #"/run/current-system/sw/bin/bash -c '/run/current-system/sw/bin/gocryptfs /var/media/nas/%i /var/uncrypt/%i -allow_other -config $GOCONF -passfile $PASSFILE'";
      };
    };
    

  });  
}


