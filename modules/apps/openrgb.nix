{ lib, config, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.openrgb.enable = lib.mkOption {
    description = "Configure openrgb app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.openrgb.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    boot.kernelModules = [ "i2c-dev" ];
    boot.kernelParams = [ "acpi_enforce_resources=lax" ];

    services.hardware.openrgb = { 
      enable = true; 
      package = pkgsUnstable.openrgb;
      motherboard = "amd"; 
    };

    environment.systemPackages = with pkgsUnstable; [
      i2c-tools
    ];

    hardware.i2c = {
      group = "i2c";
      enable = true;
    };

    systemd.services.openrgb-gskill = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        [Desktop Entry]
        Type=Application
        Name=GskillRGB
        Exec=openrgb --profile gskillOff
        X-GNOME-Autostart-enabled=true" > /home/"${user}"/.config/autostart/gskill.desktop
      '';
    };


  });
}
