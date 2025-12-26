{ config, lib, pkgs, ... }:

let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;

in
{

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Nixos basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  system.stateVersion = "24.11"; # never change this
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  programs.nix-index.enable = lib.mkDefault true;
  programs.command-not-found.enable = lib.mkDefault false;

  nix.settings.download-buffer-size = 524288000;
  nix.settings.experimental-features = lib.mkDefault [
    "nix-command"
    "flakes"
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Custom modules - mle modules
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # TODO : retirer les modules d'ici : le base.nix doit être non flakisé, donc
  # comme il n'y a pas d'imports il ne doit pas contenir de modules
  # juste un système basique
  # donc créer un rôle serveur par défaut ou quelque chose comme cela
  
  mle = {

    apps = {
      bash.enable = true;
      fish.enable = true;
      nano.enable = true;
    };
    
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Linux basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];

      # TODO Framework problem for LED - module framework
    #boot.kernelParams = [
    #  "module_blacklist=hid_sensor_hub"
    #];

  environment.etc."systemd/user.conf" = {
    enable = lib.mkDefault true;
    text = lib.mkDefault ''
      [Manager]
      DefaultTimeoutStopSec=5s
      DefaultTimeoutAbortSec=5s
    '';
  };

  services = {
    fstrim.enable = lib.mkDefault true;
    fwupd.enable = lib.mkDefault true;
    openssh.enable = lib.mkDefault true;
  };

  users.groups = {
    udev.members = lib.mkDefault normalUsers;
    users.members = lib.mkDefault normalUsers;
    input.members = lib.mkDefault normalUsers;
    video.members = lib.mkDefault normalUsers;
    wheel.members = lib.mkDefault normalUsers;
  };


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Security basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Firewall
  networking.firewall = {
    enable = lib.mkDefault true;
  };  

  # Antivirus
  services.clamav = {
    daemon.enable = lib.mkDefault false;
    updater.enable = lib.mkDefault false;
  };



  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Packages basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  environment.systemPackages = with pkgs; [
    # Nix tools
    nh nix-prefetch-git nix-prefetch-github nixpkgs-fmt nixos-icons

    # Filesystems
    e2fsprogs btrfs-progs dosfstools ntfs3g mtpfs exfat exfatprogs

    # CLI tools
    git util-linux pciutils lshw dmidecode smartmontools ncdu tree
    lm_sensors duf neofetch htop vim bat
    p7zip gnutar
    cron rsync restic wget curl
    gocryptfs ghostscript
    fd ripgrep-all fzf eza
    lazygit
    jq
    lsof hwinfo
  ];


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Network basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  networking = {
    hostName = lib.mkDefault "nixos";
    useDHCP = lib.mkDefault true;
  };  


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Grub basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  boot = {
    loader = {

      efi = {
        canTouchEfiVariables = lib.mkDefault true;
        efiSysMountPoint = lib.mkDefault "/efi";
      };

      grub = {
        enable = lib.mkDefault true;
        device = lib.mkDefault "nodev";
        efiSupport = lib.mkDefault true;
        enableCryptodisk = lib.mkDefault true;
        useOSProber = lib.mkDefault true;
      };
    };

    plymouth = {
      enable = lib.mkDefault true;
    };
    
  };  


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Locale basics
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  time = { timeZone = lib.mkDefault "Europe/Paris"; };

  i18n = {
    defaultLocale = lib.mkDefault "fr_FR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = lib.mkDefault "fr_FR.UTF-8";
      LC_IDENTIFICATION = lib.mkDefault "fr_FR.UTF-8";
      LC_MEASUREMENT = lib.mkDefault "fr_FR.UTF-8";
      LC_MONETARY = lib.mkDefault "fr_FR.UTF-8";
      LC_NAME = lib.mkDefault "fr_FR.UTF-8";
      LC_NUMERIC = lib.mkDefault "fr_FR.UTF-8";
      LC_PAPER = lib.mkDefault "fr_FR.UTF-8";
      LC_TELEPHONE = lib.mkDefault "fr_FR.UTF-8";
      LC_TIME = lib.mkDefault "fr_FR.UTF-8";
    };
  };

  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    keyMap = lib.mkDefault "fr";
  };





}
