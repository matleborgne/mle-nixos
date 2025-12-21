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
  networking.hostName = "nix-x2";

  # Testing kernel because of new hardware
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Hardware - suspend black screen workaround
  boot.kernelParams = [
    "amdgpu.runpm=0" # désactive le runtime power management
    "amdgpu.aspm=0"  # désactive Active State Power management (PCIE)
    "amdgpu.gpu_recovery=1"
  ];



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
      openrgb.enable = true;
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
      vscode.enable = true;
    };
    
    misc = {
      libvirt.enable = true;
      mleupdater.enable = true;
      sshfs.enable = true;
    };

    secrets = {
      hm-mleborgne.enable = true;
      libvirt-vm103.enable = true;
      libvirt-vm104.enable = true;
      libvirt-vm901.enable = true;
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

  security.pki.certificateFiles = [];


}
