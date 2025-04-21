{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.cockpit-podman.enable = lib.mkOption {
    description = "Configure COCKIT PODMAN module";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.cockpit-podman.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.apps.cockpit.enable = lib.mkForce true;
    mle.misc.podman.enable = lib.mkForce true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # REV-PARSE : git rev-parse HEAD in flake directory

    environment.systemPackages = with pkgs; [
      (builtins.getFlake "github:matleborgne/cockpit-podman/3e5b86026543c85059d04c99a9b7a7ddc9e07836").packages.x86_64-linux.default
    ];
      
  };
}
