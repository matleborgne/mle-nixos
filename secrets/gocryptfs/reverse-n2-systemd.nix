{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SECRETS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Secrets are configuration very specific but concerning
# in terms of security, not to be on github

{

    options.mle.secrets.gocryptfs.reverse-n2-systemd.enable = lib.mkOption {
        description = "Configure gocryptfs.reverse-n2-systemd server";
        type = lib.types.bool;
        default = false;
    };
    
    config = lib.mkIf config.mle.secrets.gocryptfs.reverse-n2-systemd.enable {
        
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # /!\ Prefer filesystem approch if possible /!\
    # It's a cleaner approach as it does not rely too much on systemd-services
    # This approach will generate 2 services for each mount, which can be heavy to manage


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Secrets configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    systemd.services = with builtins;

      let

        # Service which will MOUNT the filesystem
        mount = shortName: relPath: {
          name = "gocryptfsRev-mount-${shortName}";
          value = {
            enable = true;
            wantedBy = [ "multi-user.target" ];
            after = [ "gocryptfsRev-initr-${shortName}.service" ];
            serviceConfig = {

              # Stop files being accidentally written to unmounted directory
              ExecStartPre = [
                "${pkgs.coreutils}/bin/mkdir -m 0500 -pv /cipher/${relPath}"
                "${pkgs.e2fsprogs}/bin/chattr +i /cipher/${relPath}"
              ];
              ExecStart = ''
                ${pkgs.gocryptfs}/bin/gocryptfs -reverse -allow_other -passfile /passfile "/plain/${relPath}" "/cipher/${relPath}"
              '';
              KillMode = "process";
              Restart = "on-failure";
            }; 
          };
          
        };

        # Service which will INIT the filesystem if not existing
        initr = shortName: relPath: {
          name = "gocryptfsRev-initr-${shortName}";
          value = {
            wantedBy = [ "multi-user.target" ];
            script = ''
              if [ "$(${pkgs.gocryptfs}/bin/gocryptfs -reverse -info /plain/${relPath} | grep -c 'Creator')" -lt 1 ] ; then
                ${pkgs.gocryptfs}/bin/gocryptfs -reverse -init "/plain/${relPath}" -passfile /passfile
              fi
            '';
          };
          
        };

      in
        # Put below your mounts, following the form
        # (fs "short_name_for_the_service" "relative_path_under_/plain")
        # inside the list

        listToAttrs [        
          (initr "shortName1" "relPath1") (initr "shortName2" "relPath2") (initr "shortName3" "subdir_here/relPath3")
          (mount "shortName1" "relPath1") (mount "shortName2" "relPath2") (mount "shortName3" "subdir_here/relPath3")
        ];   
            

  };
}
