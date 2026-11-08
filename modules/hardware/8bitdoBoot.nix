{ config, lib, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HARDWARE
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Hardware modules are the place for customization of pieces
# of hardware (cpu, gpu, x-y-wifi card or ethernet cards, etc.)
# It does not concern software itself at all

{

  options.mle.hardware.8bitdoBoot.enable = lib.mkOption {
    description = "Configure 8bitdo-usbboot";
    type = lib.types.bool;
    default = false;
  };
  
  config = lib.mkIf config.mle.hardware.8bitdoBoot.enable (
  
  let
    allUsers = builtins.attrNames config.users.users;
    normalUsers = builtins.filter (user: config.users.users.${user}.isNormalUser) allUsers;
    utilisateur = (if builtins.length normalUsers > 0 then builtins.elemAt normalUsers 0 else "root");

    delai = 8; # secondes entre l'ouverture de session et le reset
    desactiverAutosuspend = true; # règle udev qui empêche la mise en veille des récepteurs

    peripheriques = [
  # Identifiants "vendeur:produit" à réinitialiser (voir lsusb).
  # Les récepteurs 8BitDo changent d'identité selon le mode :
  #   2dc8:3106 = 8BitDo Receiver
  #   045e:028e = même récepteur, déguisé en manette Xbox 360 (mode X-input)
      "2dc8:3106"
      "045e:028e"
    ];

    # Script de reset (déconnexion / reconnexion logique des récepteurs)
    resetScript = pkgs.writeShellApplication {
      name = "reset-usb-8bitdo";
      runtimeInputs = [ pkgs.coreutils pkgs.util-linux ];
      text = ''
        PERIPHERIQUES=(${lib.escapeShellArgs peripheriques})
        PAUSE=2
        LOG_TAG="reset-usb-8bitdo"

        log() { logger -t "$LOG_TAG" "$*"; echo "$*"; }

        if [[ $EUID -ne 0 ]]; then
          echo "Ce script doit être lancé en root." >&2
          exit 1
        fi

        targets=()
        for dev in /sys/bus/usb/devices/*; do
          [[ -f "$dev/idVendor" && -f "$dev/authorized" ]] || continue
          id="$(<"$dev/idVendor"):$(<"$dev/idProduct")"
          for cible in "''${PERIPHERIQUES[@]}"; do
            if [[ "$id" == "$cible" ]]; then
              targets+=("$dev")
              break
            fi
          done
        done

        if [[ ''${#targets[@]} -eq 0 ]]; then
          log "Aucun périphérique trouvé parmi : ''${PERIPHERIQUES[*]}"
          exit 0
        fi

        log "''${#targets[@]} récepteur(s) trouvé(s)."

        # Déconnexion de tous les récepteurs en même temps
        for dev in "''${targets[@]}"; do
          id="$(<"$dev/idVendor"):$(<"$dev/idProduct")"
          name=$(cat "$dev/product" 2>/dev/null || echo "inconnu")
          log "Déconnexion de $(basename "$dev") [$id] $name"
          echo 0 > "$dev/authorized"
        done

        sleep "$PAUSE"

        # Reconnexion
        for dev in "''${targets[@]}"; do
          log "Reconnexion de $(basename "$dev")"
          echo 1 > "$dev/authorized"
        done

        log "Terminé."
      '';
    };

    # Petit lanceur exécuté par le démarrage automatique de Plasma
    autostartScript = pkgs.writeShellScript "reset-usb-8bitdo-autostart" ''
      sleep ${toString delai}
      /run/wrappers/bin/sudo -n ${resetScript}/bin/reset-usb-8bitdo
    '';

    # Une règle udev par identifiant
    regleUdev = p:
      let
        parts = lib.splitString ":" p;
        vid = builtins.elemAt parts 0;
        pid = builtins.elemAt parts 1;
      in
      ''ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="${vid}", ATTR{idProduct}=="${pid}", TEST=="power/control", ATTR{power/control}="on"'';
    
  
  in {
  
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Action of hardware part
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    # Autorise l'utilisateur à lancer ce script précis en root sans mot de passe.
    # Le chemin pointe dans /nix/store, en lecture seule : la règle ne peut pas être détournée.
    security.sudo.extraRules = [{
      users = [ utilisateur ];
      commands = [{
        command = "${resetScript}/bin/reset-usb-8bitdo";
        options = [ "NOPASSWD" ];
      }];
    }];

    # Démarrage automatique (lu par Plasma via /etc/xdg/autostart)
    environment.etc."xdg/autostart/reset-usb-8bitdo.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Reset récepteurs 8BitDo
      Exec=${autostartScript}
      X-KDE-autostart-phase=2
      NoDisplay=true
      Terminal=false
    '';

    # Rend la commande disponible pour les tests manuels
    environment.systemPackages = [ resetScript pkgs.usbutils ];

    # Correctif de fond possible : désactive la mise en veille USB des récepteurs
    services.udev.extraRules = lib.mkIf desactiverAutosuspend
      (lib.concatMapStringsSep "\n" regleUdev peripheriques + "\n");

  });  
}


