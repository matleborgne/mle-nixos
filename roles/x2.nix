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

  # Kernel is buggy now
  #boot.kernelPackages = pkgs.linuxPackages_zen;
  
    boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_18.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
              #https://cdn.kernel.org/pub/linux/kernel/v6.x
              url = "mirror://kernel/linux/kernel/v6.x/linux-6.18.2.tar.xz";
              sha256 = "sha256-VYxrurdJSSs0+Zgn/oB7ADmnRGk8IdOn4Ds6SO2quWo=";
        };
        version = "6.18.2";
        modDirVersion = "6.18.2";
        };
    });
    


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 2- Activation of mle.modules
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  mle = {

    apps = {
      firefox.enable = true;
      librewolf.enable = true;
      logitech.enable = true;
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
      kdenlive.enable = true;
      vscode.enable = true;
    };
    
    misc = {
      libvirt.enable = true;
      mleupdater.enable = true;
      #pci-passthrough.enable = true;
      #looking-glass.enable = true;
      sshfs.enable = true;
    };

    secrets = {
      hm-mleborgne.enable = true;
      libvirt-vm101.enable = true;
      libvirt-vm102.enable = true;
      libvirt-vm103.enable = true;
      libvirt-vm201.enable = true;
      libvirt-vm202.enable = true;
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
