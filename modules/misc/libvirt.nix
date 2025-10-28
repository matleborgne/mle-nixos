{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MISC
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Misc are configuration very specific which does not enter
# in apps, bundles, desktop or hardware categories

{

  options.mle.misc.libvirt.enable = lib.mkOption {
    description = "Enable LIBVIRT opensource virtualisation";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.misc.libvirt.enable (
    
    let
      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;

    in
    {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Misc configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      virt-manager
      OVMF OVMFFull
      virtiofsd
      libvirt qemu
      libguestfs
      spice spice-gtk
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # LIBVIRT daemon configuration
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];

        #ovmf = {
        #  enable = true;
        #  packages = [(pkgs.OVMF.override {
        #    secureBoot = true;
        #    tpmSupport = true;
        #  }).fd];
        #};
        
      };
    };
    
          
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Autostart HYPERVISOR and NAT
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.dconf = {
      enable = true;
      profiles.user.databases = [

        {
          settings = {
            "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
            };  
          };
        }

      ];
    };


    systemd.services.netstart = {
      enable = true;
      description = "start default virsh network";
      unitConfig.Type = "oneshot";
      script = "/run/current-system/sw/bin/virsh net-autostart default";
      wantedBy = [ "multi-user.target" ];
    };



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Other settings (kernel modules for KVM, user rights, etc.)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    users.groups = {
      libvirtd.members = normalUsers;
      kvm.members = normalUsers;
    };

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    virtualisation.spiceUSBRedirection.enable = true;

    
  });
}
