{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.sshfs.enable = lib.mkOption {
    description = "Configure sshfs nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.sshfs.enable (

    let
      name = "sshfs";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).sshfs;

      # Users
      mleborgne = (import ../../../secrets/users/mleborgne.var);
      pbachelier = (import ../../../secrets/users/pbachelier.var);
 
    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /srv - - - -"
      ];


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Container structure
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      containers.${name} = {

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = net.ifaceList;

        bindMounts = mleborgne.ctMounts // pbachelier.ctMounts;

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          imports = [
            ../../apps/fish.nix
            ../../misc/networkd.nix
            ../../misc/sshfs.nix
            ../../../secrets/ssh/openssh-server.nix
          ];

          mle = {
            apps = {
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
              sshfs.enable = true;
            };
            secrets.openssh-server.enable = true;
          };


          services.openssh = {
            enable = lib.mkForce true;
            settings = {
              PasswordAuthentication = false;
              PermitRootLogin = "no";
            };

            extraConfig = ''
              Match Group users
                ChrootDirectory /sftp/%u
                ForceCommand internal-sftp
                AllowTcpForwarding no
            '';
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # SFTP USERS - LIMITED USERS FOR SFTP USE
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = mleborgne.sftpMounts ++ pbachelier.sftpMounts;

          users.users.mleborgne = {
            isNormalUser = true;
            extraGroups = [ "udev" "users" "fuse" ];
            shell = lib.mkForce "/run/current-system/sw/bin/nologin";
            openssh.authorizedKeys.keys = [ mleborgne.pubkey ];
            password = mleborgne.pwd;
          };

          users.users.pbachelier = {
            isNormalUser = true;
            extraGroups = [ "udev" "users" "fuse" ];
            shell = lib.mkForce "/run/current-system/sw/bin/nologin";
            openssh.authorizedKeys.keys = [ pbachelier.pubkey ];
            password = pbachelier.pwd;
          };




        };
      };
  });
}
