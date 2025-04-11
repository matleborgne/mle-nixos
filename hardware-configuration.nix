{ config, lib, pkgs, ... }:
{

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # FSTAB
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fileSystems = {
    
    "/" = {
          device = "/dev/disk/by-uuid/54c48288-4fa9-4e79-9ebe-e28522142896";
          fsType = "ext4";
          options = [ "rw,noatime" ];
        };
        
    "/efi" = {
          device = "/dev/disk/by-uuid/FE8F-D31B";
          fsType = "vfat";
          options = [ "rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro" ];
        };
        
    "/var/media/data1" = {
          device = "/dev/disk/by-uuid/49b315e1-c785-4554-869f-c781aca3de54";
          fsType = "ext4";
          options = [ "rw,noatime" ];
        };
        
    "/home/mleborgne" = {
          device = "/var/media/data1/homes/mleborgne";
          fsType = "none";
          options = [ "bind" ];
        };
        
    "/etc/secrets" = {
          device = "/var/media/data1/homes/mleborgne/Documents/mleborgne/Logiciel/code/nixos/secrets";
          fsType = "none";
          options = [ "bind" ];
        };
        
    "/var/machines" = {
          device = "/var/media/data1/kvm";
          fsType = "none";
          options = [ "bind" ];
        };
        
    "/var/media/data2" = {
          device = "/dev/disk/by-uuid/865704da-3d06-493d-9974-b97be99fbb3a";
          fsType = "ext4";
          options = [ "rw,noatime" ];
        };
        
    "/etc/nixos" = {
          device = "/var/media/data1/homes/mleborgne/Documents/mleborgne/Logiciel/code/nixos/current";
          fsType = "none";
          options = [ "bind" ];
        };
        
  };



  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CRYPTTAB
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  environment.etc.crypttab = {
    enable = true;
    text = ''
      luks-cce0468d-6db3-437b-841f-cca5ab9a1ca8 /dev/disk/by-uuid/cce0468d-6db3-437b-841f-cca5ab9a1ca8 /etc/keys/keyfile.key luks
      luks-494abb48-0cd8-4c74-ac63-8cba565ca69a /dev/disk/by-uuid/494abb48-0cd8-4c74-ac63-8cba565ca69a /etc/keys/keyfile.key luks
    '';
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROOT DISK ENCRYPTION
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  boot.initrd = {

    luks.devices."luks-6377cea3-cada-4ed3-beda-f1debca7c571" = {
      device = "/dev/disk/by-uuid/6377cea3-cada-4ed3-beda-f1debca7c571";
      allowDiscards = true;
      preLVM = true;
      keyFile = "/keyfile1.bin";
    };

    secrets = {
      "keyfile1.bin" = "/etc/keys/keyfile.key";
    };

  };
  


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # OTHER HARDWARE AUTOMATIONS
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  boot.loader.efi.efiSysMountPoint = "/efi";

  mle.hardware.rtl8125.enable = true;
  
  mle.hardware.amdcpu.enable = true;
  
  swapDevices = [{
    device = "/var/media/data1/swapfile";
    size = 63910;
  }];
  

}

