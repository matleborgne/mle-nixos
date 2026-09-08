{ lib, config, pkgs, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.kdenlive.enable = lib.mkOption {
    description = "Configure kdenlive app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.kdenlive.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

    sam2PythonEnv = pkgs.python3.withPackages (ps: with ps; [
      sam2 opencv4 pillow iopath hydra-core tqdm torchvision torchvision-bin cuda-bindings
    ]);

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = [
      pkgsUnstable.kdePackages.kdenlive   # version récente via unstable, cf. contrainte 1
      #sam2PythonEnv
    ];


    systemd.services.shortcut-kdenlive = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        echo "[Desktop Entry]
        Type=Application
        Name=Kdenlive
        Exec=kdenlive
        Icon=kdenlive" > /home/"${user}"/.local/share/applications/kdenlive.desktop
      '';
    };


  });
}
