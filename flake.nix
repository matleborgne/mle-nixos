{
  description = "mle-202602";

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Inputs - Every external data source
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";

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
    nixpkgs-unstable,
    utils,
    home-manager,
    ...
  } @inputs:

    let

      # ~~~~~~~
      # System
      # ~~~~~~~

      system = "x86_64-linux";
      hostPlatform = "x86_64-linux";
      lib = nixpkgs.lib;

      nixpkgsConfig = {
        allowUnfree = true;
      };

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig; 
      };

      # ~~~~~~~
      # Modules
      # ~~~~~~~

      nixosModules = {
        default = import ./modules;
        secrets = import ./secrets;
      };

      baseModules = [
        nixosModules.default
        nixosModules.secrets
        home-manager.nixosModules.default
        ./base.nix
        { nixpkgs.config = nixpkgsConfig; }
      ];

      isoModules = [
        ({ pkgs, modulesPath, ... }: {
          imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix") ];
          environment.systemPackages = [ pkgs.neovim ];
        })
      ];

      # ~~~~~~~
      # Roles
      # ~~~~~~~

      roles = builtins.filter (x: x != null)
                (lib.mapAttrsToList (name: type:
                  if type == "regular" && lib.hasSuffix ".nix" name
                  then lib.removeSuffix ".nix" name
                  else null
                ) (builtins.readDir ./roles));
        

      roleSpecificModules = {
        lx600Iso = isoModules;
      };

      nixosConfigurations = builtins.listToAttrs (map (r: {
        name = r;
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs hostPlatform pkgsUnstable;
          };
          modules = baseModules
            ++ [ ./roles/${r}.nix ]
            ++ (if builtins.hasAttr r roleSpecificModules then roleSpecificModules.${r} else []);
        };
      }) roles);


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    in {
      inherit nixosConfigurations;
    };
}
