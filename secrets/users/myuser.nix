{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# USERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Users modules are places for home-manager configurations
# for specific users across machines

let
  username = "myuser";

in
{

  options.mle.secrets."hm-${username}".enable = lib.mkOption {
    description = "Configure USER";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.secrets."hm-${username}".enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configuration of user (nixos-scale)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "udev" "users" "input" "video" "wheel" "fuse" "networkmanager" ];    
    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Configuration of user (home-manager)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    home-manager.users."${username}" = {
      programs.home-manager.enable = true;

      home = {
        stateVersion = "24.11";
      
        inherit username;
        homeDirectory = "/home/${username}";

        # Package specific to user
        packages = with pkgs; [
          btop
        ];
      };

    };
    
  };
}
