{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.jellyfin.enable = lib.mkOption {
    description = "Configure jellyfin app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.jellyfin.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #nixpkgs.config.allowUnfree = lib.mkForce true;

    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    #environment.systemPackages = [
    #  pkgs.jellyfin
    #  pkgs.jellyfin-web
    #  pkgs.jellyfin-ffmpeg
    #];

  };
}
