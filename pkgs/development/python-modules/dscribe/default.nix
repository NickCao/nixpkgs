{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  scipy,
  ase,
  joblib,
  sparse,
  pybind11,
  scikit-learn,
}:

buildPythonPackage rec {
  pname = "dscribe";
  version = "2.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "singroup";
    repo = "dscribe";
    tag = "v${version}";
    fetchSubmodules = true; # Bundles a specific version of Eigen
    hash = "sha256-2JY24cR2ie4+4svVWC4rm3Iy6Wfg0n2vkINz032kPWc=";
  };

  build-system = [
    setuptools
    pybind11
  ];

  dependencies = [
    numpy
    scipy
    ase
    scikit-learn
    joblib
    sparse
  ];

  meta = {
    description = "Machine learning descriptors for atomistic systems";
    homepage = "https://github.com/SINGROUP/dscribe";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sheepforce ];
  };
}
