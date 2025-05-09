{
  lib,
  buildPythonPackage,
  fetchPypi,
  packaging,
  setuptools,
  setuptools-scm,
  sip,
}:

buildPythonPackage rec {
  pname = "pyqt-builder";
  version = "1.18.1";
  pyproject = true;

  src = fetchPypi {
    pname = "pyqt_builder";
    inherit version;
    hash = "sha256-P3o6JxWUeik6l1MKdv1Z8TCfy45XpYMPRcef5ySbOZg=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    sip
  ];

  pythonImportsCheck = [ "pyqtbuild" ];

  # There aren't tests
  doCheck = false;

  meta = with lib; {
    description = "PEP 517 compliant build system for PyQt";
    homepage = "https://github.com/Python-PyQt/PyQt-builder";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
