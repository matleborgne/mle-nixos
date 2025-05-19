{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.seedbox.enable = lib.mkOption {
    description = "Configure seedbox nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.seedbox.enable (

    let
      name = "seedbox";
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).seedbox;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /var/lib/qbittorrent - - - -"
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
          "/var/lib/qbittorrent" = { hostPath = "/var/lib/qbittorrent"; isReadOnly = false; };
          "/etc/wireguard" = { hostPath = "/etc/nixos/build/secrets/wireguard/proton-client"; isReadOnly = false; };
          "/srv/bkp/lxc/556-seedbox" = { hostPath = "/srv/bkp/lxc/556-seedbox"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
          "/srv/sof" = { hostPath = "/srv/sof"; isReadOnly = false; };
          "/srv/vid" = { hostPath = "/srv/vid"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };

      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [
            "d /var/lib/qbittorrent 755 qbittorrent qbittorrent -"
            "d /srv/bkp/lxc/556-seedbox - - - -"
          ];

          imports = [
            ../../apps/wireguard/proton-client.nix
            ../../apps/qbittorrent.nix
            ../../apps/fish.nix
            ../../forks/qbittorrent.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps = {
              wireguard.proton-client.enable = true;
              qbittorrent.enable = true;
              fish.enable = true;
            };
            misc = {
              networkd.enable = true;
            };
          };

          # Change user ID
          system.activationScripts.chgUid = ''
            systemctl stop qbittorrent

            usermod -u 1000 -g 100 qbittorrent
            find /var -uid 888 -exec chown -v -h 1000 '{}' \;
            find /var -gid 888 -exec chgrp -v 100 '{}' \;

            systemctl start qbittorrent
          '';


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          environment.systemPackages = with pkgs; [ restic ];

          services.restic.backups = {

            qbittorrent = {
              initialize = false;
              repository = "/srv/bkp/lxc/556-seedbox";
              paths = [ "/var/lib/qbittorrent" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Wed 15:30";
                Persistent = "true";
              };
            };

          };



        };
      };
  });
}
