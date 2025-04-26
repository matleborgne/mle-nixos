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

      pwd = (import ../../../secrets/keys/passwords);
      pubkeys = (import ../../../secrets/keys/pubkeys);

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

        bindMounts = {
          "/sftp/mleborgne/srv" = { hostPath = "/srv"; isReadOnly = false; };
        };

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
            ../../../secrets/users/mleborgne.nix
            ../../../secrets/users/pbachelier.nix
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
          # SFTP USERS
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


          # Dont forget to import the module before
          mle.users = {
            mleborgne.enable = true;
            pbachelier.enable = true;
          };


          systemd.tmpfiles.rules = [
            "d /sftp/mleborgne 755 root root -"
            "d /sftp/mleborgne/srv 750 mleborgne users -"
            "d /sftp/pbachelier/srv 750 pbachelier users -"
          ];

          users.users.mleborgne = {
            openssh.authorizedKeys.keys = [ pubkeys.mleborgne ];
            shell = lib.mkForce "/run/current-system/sw/bin/nologin";
            password = pwd.mleborgne;
          };

          users.users.pbachelier = {
            openssh.authorizedKeys.keys = [ pubkeys.pbachelier ];
            shell = lib.mkForce "/run/current-system/sw/bin/nologin";
            password = pwd.pbachelier;
          };




        };
      };
  });
}
