{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.scrutiny.enable = lib.mkOption {
    description = "Configure scrutiny app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.scrutiny.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = with pkgs; [
      scrutiny scrutiny-collector
      smartmontools
    ];

    networking.firewall = {
      allowedTCPPorts = [ 80 8080 ];
    };

    services.scrutiny = {
      enable = true;
      openFirewall = true;
    };


    systemd.services."manualCollector" = {
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${pkgs.scrutiny-collector}/bin/scrutiny-collector-metrics run --debug --log-file /tmp/collector.log '';
      };
    };

    systemd.timers."manualCollector" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/15";
        Unit = "manualCollector.service";
      };
    };


    services.nginx = {
      enable = true;
  
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
  
      virtualHosts = {
        "scrutiny.example.com" = {
          http2 = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080/";
            proxyWebsockets = true;
          };

        };
      };
    };  

  };
}
