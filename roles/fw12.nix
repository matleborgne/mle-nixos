{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ROLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 1- Change base.nix config defined by "lib.mkDefault",
# 2- Activate modules by mle.module.enable = true,

# 3- Note it is possible to override config present in some module
# To do that, use "lib.mkForce"

{

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 1- Modification of base.nix (defined by lib.mkDefault)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Hostname
  networking.hostName = "nix-fw12";

  # Kernel is buggy now
  boot.kernelPackages = pkgs.linuxPackages_zen; 

  # FW12 screen rotation

  # Manual alternative
  #boot.initrd.kernelModules = [ "pinctrl_tigerlake" ];

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 2- Activation of mle.modules
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  mle = {

    apps = {
      firefox.enable = true;
      librewolf.enable = true;
      thunderbird.enable = true;      
      video-downloader.enable = true; 
      podman.enable = true;
    };

    bundles = {
      #datapro.enable = true; # replace by declarative flatpaks
      development.enable = true;
      gaming.enable = true;
      multimedia.enable = true;
      office.enable = true;
    };

    desktop.gnome.mleborgne.enable = true;

    flatpaks = {
      #kdenlive.enable = true;
      vscode.enable = true;
    };
    
    misc = {
      mleupdater.enable = true;
      sshfs.enable = true;
    };

    services = {
      system-gocryptfs.enable = true;
      user-fstab-mount.enable = true;
    };

    secrets = {
      hm-mleborgne.enable = true;
      openssh-server.enable = true;
      openssh-client-mleborgne.enable = true;
    };
    
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 3- Modification of mle.module (through lib.mkForce)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Example with force bluetooth disabled
  # Bad example because here we disable a full module, so we could do
  # mle.bluetooth.enable = lib.mkForce false;
  #hardware.bluetooth.enable = lib.mkForce false;

  # Works better for example with a gsettings parameter to override (font size, etc.)

}
