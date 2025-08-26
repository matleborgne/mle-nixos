{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.undervolting.enable = lib.mkOption {
    description = "Configure UNDERVOLTING app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.undervolting.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      lact
      fancontrol-gui
    ];

    systemd.packages = with pkgs; [ lact ];
    systemd.services.lactd.wantedBy = ["multi-user.target"];

    hardware.amdgpu.overdrive = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
    
  };
}
