{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FLATPAKS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Flatpaks are flatpak apps declarative configuration
# Pay attention that flatpak has risk to be inpure
# As it could not be avoided users imperative commands
# directly in the terminal
# So avoid using flatpaks in strict pure evaluations

{

  options.mle.flatpaks.vscode.enable = lib.mkOption {
    description = "Enable VSCODE flatpak";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.flatpaks.vscode.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

    pythonDeps = ''
      #!/bin/bash
      pip3 install --prefix=/var/data/python \
        jupyter ipykernel pipdeptree \
        pandas numpy openpyxl xlrd \
        matplotlib seaborn plotly \
        scikit-learn scikit-learn-extra hdbscan \
        statsmodels jellyfish chardet levenshtein \
        chainladder sparse dill patsy
    '';

  in {
    
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mle.misc.flatpak.enable = lib.mkForce true;


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    systemd.user.services.flatpak-vscode = {
      reloadIfChanged = true;
      wantedBy = [ "default.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak install --or-update --noninteractive com.vscodium.codium

        cat << EOF | flatpak run --command=/bin/bash com.vscodium.codium
          echo ${pythonDeps} > /var/data/vscode-pythonDeps.sh
        EOF

        flatpak run --command=/var/data/vscode-pythonDeps.sh com.vscodium.codium
      '';
    };

    systemd.services.flatpak-shortcut = {
      wantedBy = [ "multi-user.target" ];
      script = ''
        echo "[Desktop Entry]
        Type=Application
        Name=VSCodium
        Exec=flatpak run com.vscodium.codium
        Icon=visual-studio-code" > /home/"${user}"/.local/share/applications/codium.desktop
      '';
    };
    
  });

}
