{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.containers.nspawn.youtubedl.enable = lib.mkOption {
    description = "Configure youtubedl nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.containers.nspawn.youtubedl.enable (

    let
      address = [ "10.22.0.155/24" ]; # change this accord to desired local IP

    in {

      containers.youtubedl = {
        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = [ "enp3s0" ];

        bindMounts = {
          "/var/lib/youtubedl" = { hostPath = "/var/lib/nspawn/youtubedl"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, ... }: {

          imports = [
            ../../apps/fish.nix
          ];
      
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Main services
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          mle.apps.fish.enable = true;
          networking.firewall.enable = false;

          environment.systemPackages = with pkgs; [
            bat gocryptfs yt-dlp
          ];

          system.activationScripts.mkYoutubedlDirs = ''
            install -d -m 0755 -o "root" -g users "/var/lib/youtubedl" || true
            install -d -m 0755 -o "root" -g users "/mnt/uncrypt" || true
          '';

          systemd.services."youtubedl" = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''${pkgs.bash}/bin/bash /var/lib/youtubedl/start-services.sh'';
            };
          };

          systemd.timers."youtubedl" = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "23:35";
              Unit = "youtubedl.service";
            };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Network
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          system.stateVersion = "24.11";

          networking = {
            hostName = "youtubedl";

            useNetworkd = true;
            useDHCP = false;
            useHostResolvConf = false;
          };

          systemd.network = {
            enable = true;
            networks = {
              "40-mv-enp3s0" = {
                matchConfig.Name = "mv-enp3s0";
                networkConfig.DHCP = "yes";
                dhcpV4Config.ClientIdentifier = "mac";
                inherit address;
              };
            };
          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Auto Backup
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          environment.systemPackages = with pkgs; [ restic ];

          services.restic.backups = {

            nextcloud-app = {
              initialize = false;
              repository = "/mnt/nfs/bkp/lxc/553-nextcloud/app";
              paths = [ "/var/lib/nextcloud" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Wed 05:30";
                Persistent = "true";
              };
            };

            nextcloud-db = {
              initialize = false;
              repository = "/mnt/nfs/bkp/lxc/553-nextcloud/db";
              paths = [ "/var/lib/postgresql" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Wed 07:30";
                Persistent = "true";
              };
            };

          };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Other services
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        };
      };
  });
}
