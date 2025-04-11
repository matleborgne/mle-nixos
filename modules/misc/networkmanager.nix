{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

	options.mle.misc.networkmanager.enable = lib.mkOption {
		description = "Enable NETWORKMANAGER service";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.misc.networkmanager.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;

  in {
		
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    users.groups.networkmanager.members = normalUsers;

    networking = {
      useDHCP = false;

      networkmanager = {
        enable = true;
      };
    };

	});

}
