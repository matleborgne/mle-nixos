{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SECRETS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Secrets are configuration very specific but concerning
# in terms of security, not to be on github

{

    options.mle.secrets.gocryptfs.reverse-n2-fs.enable = lib.mkOption {
        description = "Configure gocryptfs.reverse-n2-fs mounts";
        type = lib.types.bool;
        default = false;
    };
    
    config = lib.mkIf config.mle.secrets.gocryptfs.reverse-n2-fs.enable {
        
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # /!\ CRASH WARNING /!\
    # Don't activate this module in your nixos host when "rebuild switch"
    # or it could lead to host crash, with no distant access anymore
      
    # Only activate it on a guest (nixos-container or vm)
    # Or rebuild boot and reboot to be safe
      

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Secrets configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    fileSystems = with builtins;
  
      let
        fs = mountPoint: {
          name = "${mountPoint}";
          value = {
            device = "/plain/${mountPoint}";
            mountPoint = "/cipher/${mountPoint}";
            fsType = "fuse./run/current-system/sw/bin/gocryptfs";
            options = [ "rw" "reverse" "allow_other" "passfile=/passfile" ];
          };
        };
    
      in
        # Put below your mounts, following the form
        # (fs "relative_path_under_/plain")
        # inside the list
      
        listToAttrs [
          (fs "first_dir") (fs "second_dir") (fs "subdir_here/third_dir")
        ];      


  };
}
