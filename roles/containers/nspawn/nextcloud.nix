{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ROLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 1- Change base.nix config defined by "lib.mkDefault",
# 2- Activate modules by mle.module.enable = true,

# 3- Note it is possible to override config present in some module
# To do that, use "lib.mkForce"

let
  address = [ "10.22.0.153/24" ];

in
{

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 1- Modification of base.nix (defined by lib.mkDefault)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Hostname
  networking.hostName = "nextcloud";

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages;



  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 2- Activation of mle.modules
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  mle = {

    apps = {
      fish.enable = true;
      nextcloud.enable = true;   
    };
    
    misc = {
      networkd.enable = true;
    };
    
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 3- Modification of mle.module (through lib.mkForce)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  services.nextcloud = {
    # Very sensitive Nextcloud-installer about trusted domain : only IP without mask or anything else
    settings = { trusted_domains = [ (builtins.elemAt (builtins.split "/" (builtins.elemAt address 0)) 0) ]; };
    config = { adminpassFile = "/ncpassfile"; };
  };

  systemd.network."40-mv-enp3s0" = { inherit address };

  environment.systemPackages = with pkgs; [ restic ];

  services.restic.backups = {

    nextcloud-app = {
      initialize = false;
      repository = "/mnt/nfs/bkp/lxc/553-nextcloud/app";
      paths = [ "/var/lib/nextcloud" ];
      passwordFile = "/passfile";
      pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
      timerConfig = {
        OnCalendar = "Wed 05:30";
        Persistent = "true";
      };
    };

    nextcloud-db = {
      initialize = false;
      repository = "/mnt/nfs/bkp/lxc/553-nextcloud/db";
      paths = [ "/var/lib/postgresql" ];
      passwordFile = "/passfile";
      pruneOpts = [ "--keep-weekly 5" "--keep-monthly 3" ];
      timerConfig = {
        OnCalendar = "Wed 07:30";
        Persistent = "true";
      };
    };

  };


}
