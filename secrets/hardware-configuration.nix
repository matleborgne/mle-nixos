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
        


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CRYPTTAB
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  environment.etc.crypttab = {
    enable = true;
    text = ''
      luks-aaa /dev/disk/by-uuid/aaa keyfile luks
    '';
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROOT DISK ENCRYPTION
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  boot.initrd = {

    luks.devices."luks-bbb" = {
      device = "/dev/disk/by-uuid/bbb";
      allowDiscards = true;
      preLVM = true;
      keyFile = "/keyfile1.bin";
    };

    secrets = {
      "keyfile1.bin" = "keyfile";
    };

  };
  

}

