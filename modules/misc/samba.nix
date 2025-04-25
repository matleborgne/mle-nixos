{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.samba.enable = lib.mkOption {
    description = "Enable samba service";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.samba.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;

  in {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    networking.firewall.enable = lib.mkDefault false;

    #users.groups.fuse.members = normalUsers;
    #networking.firewall.allowPing = true;

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      publish.enable = true;
      publish.userServices = true;
      nssmdns4 = true;
      enable = true;
      openFirewall = true;
    };


    services.samba = {
      enable = true;
      package = pkgs.samba4Full;

      securityType = "user";
      openFirewall = true;

      settings = {
      
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "%h server";
          "dns proxy" = "no";
          #"passdb backend" = "tdbsam";
          "passwd program" = "/run/current-system/sw/bin/passwd %u";
          "pam password change" = "yes";
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
          "unix extensions" = "yes";
          "create mask" = "0777";
          "directory mask" = "0777";
          "time server" = "no";
          "server min protocol" = "SMB2_02";
          #"hosts allow" = "10.22.0.0/24 127.0.0.1 localhost";
          #"hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
        };

        public = {
          "path" = "/srv/shr";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
        };

        # Example of customization here
        mlepro = {
          "path" = "/srv/mle";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "mlepro";
          #"force group" = "groupname";
        };

      };

    };

        
  });
}
