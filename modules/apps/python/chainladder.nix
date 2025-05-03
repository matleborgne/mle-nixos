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
          chainladder = pkgs.buildPythonPackage rec {
            pname = "chainladder";
            version = "0.8.24";
            pyproject = true;

            src = pyPkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-RKoDlqQRzYBl8gaiM1VF5sjPJVRWrsGseuefAMm/ojk=";
            };

            build-system = with pyPkgs; [
              setuptools
              setuptools-scm
            ];

            dependencies = with pyPkgs; [
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

            nativeCheckInputs = with pyPkgs; [
              hypothesis
            ];
          };

    in
      [ (python3.withPackages (ps: with ps; [ chainladder ])) ];

  };
}
