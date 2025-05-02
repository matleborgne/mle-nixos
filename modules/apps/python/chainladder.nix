{ lib, config, pkgs, ... }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# APPS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apps modules are the place for customization of individual apps
# This is not the place for bundles, hardware, desktop, etc.
# Only for individual applications

{

  options.mle.apps.python.chainladder.enable = lib.mkOption {
    description = "Configure PYTHON CHAINLADDER library";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.mle.apps.python.chainladder.enable {

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Recursive activation of other mle.<modules>
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Activation and customization of APP
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    environment.systemPackages =
      let
        chainladder = pkgs.python3Packages.buildPythonApplication rec {
          pname = "chainladder";
          version = "0.8.24";
          pyproject = true;

          src = pkgs.python3Packages.fetchPypi {
            inherit pname version;
            hash = "sha256-RKoDlqQRzYBl8gaiM1VF5sjPJVRWrsGseuefAMm/ojk=";
          };

          build-system = with pkgs.python3Packages; [
            setuptools
            setuptools-scm
          ];

          dependencies = with pkgs.python3Packages; [
            attrs
            py
            setuptools
            scikit-learn
            matplotlib
            sparse
            pandas
            dill
            patsy
            packaging
          ];

          nativeCheckInputs = with pkgs.python3Packages; [
            hypothesis
          ];
        };

      in
        [ chainladder ];

  };
}
