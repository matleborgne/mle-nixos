{
  description = "202503-refonte";

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Inputs - Every external data source
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    #nix-colors.url = "github:Misterio77/nix-colors";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Outputs - Variables
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  outputs = {
    self,
    nixpkgs,
    home-manager,
    chainladder-python,
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
      ] ++ (import (builtins.toPath ./modules/imports.nix))
        ++ (import (builtins.toPath ./secrets/imports.nix));


    in {

    nixosConfigurations = {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      lx600 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ [ ./roles/lx600.nix ];
      };


      yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ [ ./roles/yoga.nix ];
      };


      n2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ [ ./roles/n2.nix ];
      };


      sgpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ [ ./roles/sgpc.nix ];
      };


      ridge = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = basicModules ++ [ ./roles/ridge.nix ];
      };

    };

  };
}
