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

    environment.systemPackages = with pkgs; [
      gocryptfs
    ];

    # With PASSWORD PROMPT
    systemd.services."gocryptfs@" = {
      description = "Specified by i gocryptfs mount";      
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        RemainAfterExit = true;
        EnvironmentFile = [ "/home/${user}/.gocryptfs/%i.env" ];
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c \
            'test -d "$CIPHERDIR" || exit 0 \
            test -d "$MOUNTDIR" || exit 0'
        '';
        ExecStart = ''
          ${pkgs.bash}/bin/bash -c \
            '${pkgs.systemd}/bin/systemd-ask-password Password | \
            ${pkgs.gocryptfs}/bin/gocryptfs \
              ''${CIPHERDIR} ''${MOUNTDIR} \
              -config ''${CONFIG} \
              -extpass "${pkgs.systemd}/bin/systemd-ask-password Password for %i" \
              ''${ARGS}'
        '';
      };
    };

    
    # With PASSFILE
    systemd.services."gocryptfs-passfile@" = {
      description = "Specified by i gocryptfs mount with passfile";      
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "forking";
        RemainAfterExit = true;
        EnvironmentFile = [ "/home/${user}/.gocryptfs/%i.env" ];
        ExecStartPre = ''
          ${pkgs.bash}/bin/bash -c \
            'test -d "$CIPHERDIR" || exit 0 \
            test -d "$MOUNTDIR" || exit 0'
        '';
        ExecStart = ''
          ${pkgs.bash}/bin/bash -c \
            '${pkgs.gocryptfs}/bin/gocryptfs \
              ''${CIPHERDIR} ''${MOUNTDIR} \
              -config ''${CONFIG} \
              -passfile ''${PASSFILE} \
              ''${ARGS}'
        '';
      };
    };
    

  });  
}


