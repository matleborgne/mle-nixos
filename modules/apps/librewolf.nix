{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.librewolf.enable = lib.mkOption {
    description = "Configure LIBREWOLF";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.librewolf.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    imports = [ ../../pkgs/librewolf.nix ];
    #pkgs.callPackage /etc/nixos/build/pkgs/librewolf.nix {};

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    programs.librewolf = {
      enable = true;
      wrapperConfig.pipewireSupport = true;
      languagePacks = [ "fr" "en-US" ];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        SearchBar = "unified";

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Extensions by default (inside policies)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        ExtensionSettings = with builtins;

          let extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
          
          in listToAttrs [
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
            (extension "istilldontcareaboutcookies" "idcac-pub@guus.ninja")
            (extension "return-youtube-dislikes" "{762f9885-5a13-4abd-9c77-433dcd38b8fd}")
          ];

      };

      preferences = {

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # UI, language, features and search engine (inside preferences)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        # Language by default
        "intl.accept_languages" = "fr-fr,en-us,en";
        "intl.locale.requested" = "fr,en-US";

        #- Homepage and search engine
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";

        #- Disable autofill
        "dom.forms.autocomplete.formautofill" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.addresses.capture.enabled" = false;

        #- Disable pocket
        "signon.firefoxRelay.feature" = "disabled";
        "extensions.pocket.enabled" = false;
        "extensions.pocket.showHome" = false;

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Privacy, adds, suggestions
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        # Privacy parameters
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.clearOnShutdown.cache" = false;
        "privacy.clearOnShutdown.cookies" = false;

        #- Disable suggestions / recommendations
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.dataFeatureRecommendations.enabled" = false;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.bestmatch" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "layout.spellcheckDefault" = "0";

        #- Privacy - tracking
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.annotate_channels.strict_list.enabled" = true;
        "browser.contentblocking.category" = "strict";

      };

    };


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Importation des EXTENSIONS (manuellement pour l'instant)
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#    system.activationScripts.getFirefoxExtensions = ''
#
#      profilePath=$(find /home/mleborgne/.mozilla/firefox -type d -name "*.default")
#      extensions="
#        bitwarden-password-manager|{446900e4-71c2-419f-a6a7-df9c091e268b}
#        ublock-origin|uBlock0@raymondhill.net
#        privacy-badger17|jid1-MnnxcxisBPnSXQ@jetpack
#        istilldontcareaboutcookies|idcac-pub@guus.ninja
#        return-youtube-dislikes|{762f9885-5a13-4abd-9c77-433dcd38b8fd}
#      "
#      
#      for extension in $extensions
#      do
#        name=$(echo $extension | /run/current-system/sw/bin/awk -F "|" '{ print $1 }')
#        uid=$(echo $extension | /run/current-system/sw/bin/awk -F "|" '{ print $2 }')
#
#        /run/current-system/sw/bin/wget -nc \
#          -O $profilePath/extensions/$uid.xpi \
#          https://addons.mozilla.org/en-US/firefox/downloads/latest/$name/latest.xpi || true
#      done
#
#      chown -R mleborgne:users $profilePath/extensions
#
#    '';



  };

}
