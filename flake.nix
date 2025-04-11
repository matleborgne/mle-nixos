{
  description = "mle-nixos github flake";

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
    ...
  }
    @inputs:


    let

      baseModules = [
        { system.configurationRevision = self.rev or self.dirtyRev or null; }
        { nixpkgs.config = nixpkgsConfig; }
        nixosModules.default
        
        home-manager.nixosModules.default
        ./base.nix
      ];


      mleModules = (import (builtins.toPath ./modules/imports.nix));
            


    in {

    nixosConfigurations = {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      lx600 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = baseModules ++ mleModules ++ [
          ./roles/lx600.nix
        ];
      };


      yoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = baseModules ++ mleModules ++ [ ./roles/yoga.nix ];
      };


      sgpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = baseModules ++ mleModules ++ [ ./roles/sgpc.nix ];
      };


      ridge = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = baseModules ++ mleModules ++ [ ./roles/ridge.nix ];
      };

    };


#    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
     inherit nixosModules;

  };
}
