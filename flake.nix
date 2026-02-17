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
      system = "x86_64-linux";

      nixpkgsConfig = {
        allowUnfree = true;
      };

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig; 
      };

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

      roles = [ "tpldesktop" "lx600" "yoga" "yoga-testing" "n2" "sgpc" "ridge" "x2" ];

      nixosConfigurations = builtins.listToAttrs (map (r: {
        name = r;
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs pkgsUnstable; };
          modules = baseModules ++ [./roles/${r}.nix];
        };
      }) roles);

    in {
      inherit nixosConfigurations;

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configurations
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      #lx600Iso = nixpkgs.lib.nixosSystem {
      #  inherit system;
      #  specialArgs = { inherit inputs pkgsUnstable; };
      #  modules = baseModules ++ isoModules ++ [ ./roles/lx600Iso.nix ];
      #};

    };
  };
}
