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
  networking.hostName = "nix-n2";

  # Kernel stable
  boot.kernelPackages = pkgs.linuxPackages;



  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 2- Activation of mle.modules
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  mle = {

    apps = {
      cockpit.enable = true;
    };

    misc = {
      mdadm.enable = true;
    };

    containers.nspawn = {
      vaultwarden.enable = true;
      plexserver.enable = true;
      nextcloud.enable = true;
      wireguard-quick.enable = true;
      #youtubedl.enable = true;
      #seedbox.enable = true;
      adguardhome.enable = true;
      #rclone-cloud.enable = true;
      samba.enable = true;
      sshfs.enable = true;
    };

    secrets = {
      hm-nas.enable = true;
    };

  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 3- Modification of mle.module (through lib.mkForce)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Example with force bluetooth disabled
  # Bad example because here we disable a full module, so we could do
  # mle.bluetooth.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  # Works better for example with a gsettings parameter to override (font size, etc.)

  environment.etc.crypttab.text = lib.mkForce ''
    WD24201W4A3K13 UUID=d4eeb28f-f13a-4d86-9e7b-213e5f22e9a8 /etc/keys/keyfile.key luks,nofail
    WD2416644A0R13 UUID=cd81b37d-016c-44be-8a98-37de6c0f4970 /etc/keys/keyfile.key luks,nofail
    WD24201W4A0X05 UUID=9e6fba59-7edc-493f-8e50-50c59aab40e8 /etc/keys/keyfile.key luks,nofail
    WD24201W4A1013 UUID=5c894e54-9220-47d2-a54c-fbb5f83757b5 /etc/keys/keyfile.key luks,nofail
    WD2416644A0N08 UUID=770393e5-bc01-4c4d-9de9-05aeb51dd7ae /etc/keys/keyfile.key luks,nofail
    WD24201W4A1B10 UUID=38996162-dca0-4e8c-9593-2294ed006b38 /etc/keys/keyfile.key luks,nofail
  '';

}
