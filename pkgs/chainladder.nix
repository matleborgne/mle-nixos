{ lib, python3Packages, fetchPypi }:

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PKGS - PACKAGES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Packages are FUNCTIONS, not MODULES
# They should never been imported as a module (with import function)
# or it could be an rebuild-error

# To use a package, use something like
#let
#  myPackage = pkgs.callPackage /etc/nixos/build/pkgs/myPackage.nix {};
#in
#  environment.systemPackage = [ myPackage ] or mkShell or whatever


python3Packages.buildPythonPackage rec {
  pname = "chainladder";
  version = "0.8.24";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RKoDlqQRzYBl8gaiM1VF5sjPJVRWrsGseuefAMm/ojk=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    setuptools
    scikit-learn
    matplotlib
    sparse
    pandas
    dill
    patsy
    packaging
  ];


  propagatedBuildInputs = with python3Packages; [
    setuptools
    scikit-learn
    matplotlib
    sparse
    pandas
    dill
    patsy
    packaging
  ];

  nativeCheckInputs = with python3Packages; [
    hypothesis
  ];
}
