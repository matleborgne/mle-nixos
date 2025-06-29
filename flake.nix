{
  description = "202503-refonte";

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Inputs - Every external data source
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Outputs - Variables
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    hyprland-plugins,
    ...
  }
    @inputs:


    let

      # Define modules shared among ALL machines
      basicModules = [
        { system.configurationRevision = self.rev or self.dirtyRev or null; }
        ({ nixpkgs.config.allowUnfree = true; })
        home-manager.nixosModules.default
        ./base.nix
      ] ++ (import (builtins.toPath ./modules/imports.nix));


      # Secrets modules
      secretsModules = (import (builtins.toPath ./secrets/imports.nix));


      # Specific modules for ISO generation
      isoModules = [
        ({ pkgs, modulesPath, ... }: {
          imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix") ];
          environment.systemPackages = [ pkgs.neovim ];
        })
      ];
        

    in {

    nixosConfigurations = {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      tpldesktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ secretsModules ++ [ ./roles/tpldesktop.nix ];
      };


      lx600 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ secretsModules ++ [ ./roles/lx600.nix ];
      };

      lx600Iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ isoModules ++ [ ./roles/lx600Iso.nix ];
      };


      yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # this is the important part
        modules = basicModules ++ secretsModules ++ [ ./roles/yoga.nix ];
      };


      n2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ secretsModules ++ [ ./roles/n2.nix ];
      };


      sgpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ secretsModules ++ [ ./roles/sgpc.nix ];
      };


      ridge = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ secretsModules ++ [ ./roles/ridge.nix ];
      };

    };

  };
}
