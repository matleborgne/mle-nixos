{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

	options.mle.misc.mleupdater.enable = lib.mkOption {
		description = "Configure mle-updater";
		type = lib.types.bool;
		default = false;
	};
	
	config = lib.mkIf config.mle.misc.mleupdater.enable (

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    mainUser = builtins.elemAt normalUsers 0;

  in {
		
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  system.activationScripts.preUpdate = ''
    ${pkgs.bash}/bin/bash ${pkgs.sudo}/bin/sudo -u ${mainUser} /etc/nixos/build/scripts/github-autosync.sh
    ${pkgs.bash}/bin/bash ${pkgs.sudo}/bin/sudo -u ${mainUser} /etc/nixos/build/scripts/mlemodules.sh
  '';
    
	});

}
