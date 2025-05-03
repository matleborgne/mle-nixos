{
  lib,
  config,
  stdenv,
  python3Packages,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pytest,
}:

buildPythonPackage rec {
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

  nativeCheckInputs = with python3Packages; [
    hypothesis
  ];
}
