{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.vscode.enable = lib.mkOption {
    description = "Configure VSCODE app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.vscode.enable {

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

        userSettings = {
          "workbench.colorTheme" = "GitHub Light Default";
          "workbench.statusBar.visible" = false;
          "workbench.editor.enablePreview" = false;
          "workbench.startupEditor" = "none";
          "editor.minimap.enabled" = false;
        };

        extensions = with pkgs.vscode-extensions; [

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
