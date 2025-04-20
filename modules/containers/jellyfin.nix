{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Containers modules are the place for declaration of
# nixos-containers, through nspawn from systemd

{

  options.mle.nspawn.jellyfin.enable = lib.mkOption {
    description = "Configure jellyfin nspawn container";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.nspawn.jellyfin.enable {

  containers.plexserver = {
    autoStart = true;
    ephemeral = false;
    #bindMounts = {
    #  "/var/lib/plex" = { hostPath = "/var/lib/ct/plex"; isReadOnly = false; };
    #};

    privateNetwork = true;
    hostAddress = "10.22.0.176";  # change this
    localAddress = "10.22.0.177"; # change this, NOT THE SAME AS HOST ADDRESS

    config = { lib, config, pkgs, options, ... }: {
    #  systemd.tmpfiles.rules = [ "d /var/lib/plex 700 plex plex -" ];

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules> INSIDE THE CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    imports = [ ../apps/jellyfin.nix ];
    mle.apps.jellyfin.enable = true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Services and customization of CONTAINER
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    system.stateVersion = "24.11";

    networking = {
      useHostResolvConf = lib.mkForce false;
    };

    services.resolved.enable = true;


    };
  };
  };
}
