{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONTAINERS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{

  options.mle.containers.podman.gluetun.enable = lib.mkOption {
    description = "Configure podman gluetun container";
    type = lib.types.bool;
    default = false;
  };

  imports = lib.optional (builtins.pathExists ../../../secrets/podman/gluetun.nix) ../../../secrets/podman/gluetun.nix;

  config = lib.mkIf config.mle.containers.podman.gluetun.enable (

    let
      cname = "gluetun";

      allUsers = builtins.attrNames config.users.users;
      normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
      user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");
      uid = toString config.users.users.${user}.uid;

    in {

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Host prerequisites
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      mle.misc.podman.enable = true;

      boot.kernelModules = [ "tun" "wireguard" ];
      
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Quadlet build
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      virtualisation.oci-containers = {
        backend = "podman";
        containers.${cname} = {
          image = "docker.io/qmcgaw/gluetun:latest";
          autoStart = false;
          user = "0:0";

          environment = lib.mkDefault {
            VPN_SERVICE_PROVIDER = "enter_here";
            VPN_TYPE             = "openvpn, wireguard, etc.";
            SERVER_CITIES        = "Configure with gluetun options";
          };

          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun:/dev/net/tun"
          ];

        };
      };

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Fine tuning
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        systemd.services."podman-${cname}" = {
          serviceConfig.User = lib.mkForce user;
          serviceConfig.Restart = lib.mkForce "no";
        };

  });
}
