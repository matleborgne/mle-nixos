{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.thunderbird.enable = lib.mkOption {
    description = "Configure THUNDERBIRD app";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.thunderbird.enable {

  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    user = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.thunderbird = {
      enable = true;

      policies = {
        Preferences_intl.accept_languages = "fr";
        DisableTelemetry = true;
      };
      
      preferences = {
      
        # Language by default
        "intl.accept_languages" = "fr-fr,en-us,en";
        "intl.locale.requested" = "fr,en-US";      
      };        

    };

    environment.systemPackages = with pkgs; [
      tmux
      #protonmail-bridge-gui
      protonmail-bridge
    ];


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Bridge service
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.etc."services.d/protonmail.sh" = {
      enable = true;
      mode = "+x";
      text = ''
#!/bin/bash

set -x

case "$1" in
  start)
    # Will create a tmux session in detached mode (background) with name "protonmail"
    tmux new-session -d -s protonmail protonmail-bridge --cli
    echo "Service started."
    ;;
  status)
    # ignore this block unless you understand how tmux works and that it only lists the current user's sessions
    result=$(screen -list | grep protonmail)
    if tmux has-session -t protonmail; then
      echo "Protonmail bridge service is ON."
    else
      echo "Protonmail bridge service is OFF."
    fi
    ;;
  stop)
    # Will quit a tmux session called "protonmail" and therefore terminate the running protonmail-bridge process
    tmux kill-session -t protonmail
    echo "Service stopped."
    ;;
  *)
    echo "Unknown command: $1"
    exit 1
  ;;
esac
      '';
    };


    systemd.user.services.protonmail = {
      enable = false;
      after = [ "network.target" ];
      wantedBy = [ "graphical-session.target" ];
      description = "protonmail-bridge";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = ''/etc/services.d/protonmail.sh start'';
        ExecStop = ''/etc/services.d/protonmail.sh stop'';
      };
    };


  };
}
