{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.samba.enable = lib.mkOption {
    description = "Configure samba nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.samba.enable (

    let
      name = "samba";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).samba;

      # Users
      mlepro = (import ../../../secrets/users/mlepro.var);

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

        bindMounts = mlepro.smbMounts;

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = builtins.map (x: "d "+ x +" 700 mlepro - -") (lib.attrNames mlepro.smbMounts);

          imports = [
            ../../apps/fish.nix
            ../../misc/networkd.nix
            ../../misc/samba.nix
          ];

          mle = {
            apps = {
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
              samba.enable = true;
            };
          };

          #system.activationScripts.mleproSamba = ''
          #  useradd mlepro
          #  echo -e ${mlepro.smbpwd}\n${mlepro.smbpwd} | ${pkgs.samba4Full}/bin/smbpasswd -a mlepro  
          #  ${pkgs.samba4Full}/bin/smbpasswd -e mlepro
          #'';

          systemd.services.enrollSmbpwd = {
            enable = true;
            wantedBy = [ "default.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''
                /run/current-system/sw/bin/useradd mlepro
                echo -e ${mlepro.smbpwd}\n${mlepro.smbpwd} | /run/current-system/sw/bin/smbpasswd -a mlepro
                /run/current-system/sw/bin/smbpasswd -e mlepro
              '';
            };
          };


          services.samba.settings = {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "smbnix";
              "netbios name" = "smbnix";
              "security" = "user";
              "client max protocol" = "smb3";
              #"hosts allow" = "10.22.0. 127.0.0.1 localhost";
              #"hosts deny" = "0.0.0.0/0";
              "guest account" = "nobody";
              "map to guest" = "bad user";
            };
          } // mlepro.smbShares;


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        };
      };
  });
}
