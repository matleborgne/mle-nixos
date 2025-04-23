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
      name = "youtubedl";
      address = [ "10.22.0.155/24" ]; # change this accord to desired local IP

    in {

      systemd.tmpfiles.rules = [
        "d /var/lib/youtubedl - - - -"
      ];

      containers.${name} = {

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Container structure
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        macvlans = [ "enp3s0" ];

        bindMounts = {
          "/var/lib/youtubedl" = { hostPath = "/var/lib/youtubedl"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
        };

        config = { lib, config, pkgs, options, mle, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-enp3s0" = { inherit address; };

          imports = [
            ../../apps/fish.nix
          ];


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [
            "d /var/lib/youtubedl - - - -"
          ];

          mle.apps.fish.enable = true;
          #networking.firewall.enable = false;

          environment.systemPackages = with pkgs; [
            bat gocryptfs yt-dlp restic
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
          # Backup service
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          services.restic.backups = {

            youtubedl = {
              initialize = false;
              repository = "/mnt/nas/bkp/lxc/555-youtubedl";
              paths = [ "/var/lib/youtubedl" ];
              passwordFile = "/passfile";
              pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
              timerConfig = {
                OnCalendar = "Tue 05:25";
                Persistent = "true";
              };
            };

          };



        };
      };
  });
}
