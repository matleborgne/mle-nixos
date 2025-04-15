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

    bundles = {
    };

    desktop = {
    };
    
    misc = {
      libvirt.enable = true;
      mleupdater.enable = true;
      sshfs.enable = true;
    };

    secrets = {
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

}
