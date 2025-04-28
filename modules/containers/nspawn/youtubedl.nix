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
      net = (import ../../../secrets/keys/netIface);
      address = (import ../../../secrets/containers_ips).youtubedl;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.nixos-containers.enable = lib.mkForce true;

      systemd.tmpfiles.rules = [
        "d /var/lib/youtubedl - - - -"
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
          "/var/lib/youtubedl" = { hostPath = "/var/lib/youtubedl"; isReadOnly = false; };
          "/passfile" = { hostPath = "/etc/nixos/build/secrets/keys/restic_passfile"; isReadOnly = true; };
          "/mnt/nas/xfi" = { hostPath = "/srv/xfi"; isReadOnly = false; };
          "/mnt/nas/vid/youtube" = { hostPath = "/srv/vid/youtube"; isReadOnly = false; };
          "/mnt/nas/bkp/lxc/555-youtubedl" = { hostPath = "/srv/bkp/lxc/555-youtubedl"; isReadOnly = false; };
        };

        config = { lib, config, pkgs, options, mle, ... }: {
          system.stateVersion = "24.11";

          networking.hostName = name;
          systemd.network.networks."40-mv-${net.iface}" = { inherit address; };


          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          # Running services inside the container
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          systemd.tmpfiles.rules = [
            "d /var/lib/youtubedl - ytdl users -"
            "d /mnt/nas - ytdl users -"
          ];

          imports = [
            ../../apps/fish.nix
            ../../misc/networkd.nix
          ];

          mle = {
            apps.fish.enable = true;
            misc.networkd.enable = true;
          };

          networking.firewall.enable = false;

          environment.systemPackages = with pkgs; [
            bat gocryptfs yt-dlp restic
          ];



          systemd.services."youtubedl" = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''${pkgs.sudo}/bin/sudo -u ytdl ${pkgs.bash}/bin/bash /var/lib/youtubedl/start-services.sh'';
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
          # Ensure USER 1000
          # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          users.users.ytdl = {
            isNormalUser = true;
            uid = 1000;
            extraGroups = [ "udev" "users" ];
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
