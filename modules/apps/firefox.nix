{ lib, config, pkgs, pkgsUnstable, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.firefox.enable = lib.mkOption {
    description = "Configure FIREFOX";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.firefox.enable (

  let

    ffNav = pkgs.writeShellScriptBin "ffNav" ''
      PROFILE="$HOME/.mozilla/firefox/ffNav"
      mkdir -p "$PROFILE"
      exec ${pkgs.firefox}/bin/firefox --no-remote --profile "$PROFILE" "$@"
    '';

    ffPro = pkgs.writeShellScriptBin "ffPro" ''
      PROFILE="$HOME/.mozilla/firefox/ffPro"
      mkdir -p "$PROFILE"
      exec ${pkgs.firefox}/bin/firefox --no-remote --profile "$PROFILE" "$@"
    '';

    ffApp = pkgs.writeShellScriptBin "ffApp" ''
      PROFILE="$HOME/.mozilla/firefox/ffApp"
      mkdir -p "$PROFILE"
      exec ${pkgs.firefox}/bin/firefox --no-remote --profile "$PROFILE" "$@"
    '';

    ffVid = pkgs.writeShellScriptBin "ffVid" ''
      PROFILE="$HOME/.mozilla/firefox/ffVid"
      mkdir -p "$PROFILE"
      exec ${pkgs.firefox}/bin/firefox --no-remote --profile "$PROFILE" "$@"
    '';

  in {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages = [
      ffNav
      ffPro
      ffApp
      ffVid
    ];

    programs.firefox = {
      enable = true;
      package = pkgsUnstable.firefox;
      wrapperConfig.pipewireSupport = true;
      languagePacks = [ "fr" "en-US" ];

      policies = {
        Preferences_intl.accept_languages = "fr";
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
          ];

      };

      preferences = {

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # UI, language, features and search engine (inside preferences)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        # Language by default
        "intl.accept_languages" = "fr-fr,en-us,en";
        "intl.locale.requested" = "fr";

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

  });
}
