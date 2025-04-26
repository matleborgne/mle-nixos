{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.fish.enable = lib.mkOption {
    description = "Configure FISH shell app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.fish.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    users.defaultUserShell = pkgs.fish;

    environment.systemPackages = with pkgs; [ fish bat ];

    programs.fish = {
      enable = true;

      shellAliases = {
        nix-search = "nix-env -qaP";
        nix-install = "nix-env -iA";
        ip = "ip -c";
        ns = "nix-shell";
        nsp = "nix-shell --run fish -p";
        cat = "bat -p";
      };
      
    };
    
  };

}
