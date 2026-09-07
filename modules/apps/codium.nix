{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.codium.enable = lib.mkOption {
    description = "Configure CODIUM app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.codium.enable (
  
  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");
      
    pythonEnv = python.withPackages (ps: with ps; [
      jupyter ipykernel pipdeptree
      pandas numpy openpyxl xlrd
      matplotlib seaborn plotly
      scikit-learn statsmodels
      jellyfish chardet levenshtein
      sparse dill patsy
      flashtext chainladder
      # hdbscan            # cf. note plus bas
      # scikit-learn-extra # cf. note plus bas
    ]);

    vscodeWithExtensions = pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        ms-ceintl.vscode-language-pack-fr
        pkief.material-icon-theme
        gruntfuggly.todo-tree
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        oderwat.indent-rainbow
        christian-kohler.path-intellisense
        jnoortheen.nix-ide
        brettm12345.nixfmt-vscode
        arrterian.nix-env-selector
        timonwong.shellcheck
        github.github-vscode-theme
      ];
    };

    settingsJson = pkgs.writeText "vscodium-settings.json" (builtins.toJSON {
      "workbench.colorTheme" = "Visual Studio Light";
      "workbench.statusBar.visible" = false;
      "workbench.editor.enablePreview" = false;
      "workbench.startupEditor" = "none";
      "editor.minimap.enabled" = false;
      "window.zoomLevel" = 0.8;
      "python.defaultInterpreterPath" = "${pythonEnv}/bin/python3";
    });

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    home-manager.sharedModules = [{

      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        profiles.default.userSettings = {
          "workbench.colorTheme" = "GitHub Light Default";
          "workbench.statusBar.visible" = false;
          "workbench.editor.enablePreview" = false;
          "workbench.startupEditor" = "none";
          "editor.minimap.enabled" = false;
        };

        profiles.default.extensions = with pkgs.vscode-extensions; [

          ms-ceintl.vscode-language-pack-fr    # Pack FR
          pkief.material-icon-theme            # Pack d'icones 
          gruntfuggly.todo-tree                # Arbre montrant les TODO et FIXME

          ms-python.python                     # Python metapackage
          ms-python.vscode-pylance             # Python LSP support
          ms-toolsai.jupyter                   # Jupyter Notebook (metapack)
          oderwat.indent-rainbow               # Highlight indentation
          christian-kohler.path-intellisense   # Path auto-completion
          #github.copilot

          jnoortheen.nix-ide                   # Integrated environment for NIX
          brettm12345.nixfmt-vscode            # 
          arrterian.nix-env-selector           # NixOS environment

          timonwong.shellcheck                 # ShellCheck
          github.github-vscode-theme           # Theme github
        ];

      };  
    }];


  };

}
