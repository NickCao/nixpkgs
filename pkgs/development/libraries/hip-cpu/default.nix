{ lib
, stdenv
, fetchFromGitHub
, cmake
, tbb_2021_8
}:

stdenv.mkDerivation {
  pname = "hip-cpu";
  version = "unstable-2023-02-19";

  src = fetchFromGitHub {
    owner = "ROCm-Developer-Tools";
    repo = "HIP-CPU";
    rev = "06186c545308173babda129d6f0cb795b322a5c7";
    hash = "sha256-hM6HEpWx0hOVDoo+SQ1Q3TJCkWL0vVlTa/xGY9nOyKo";
  };

  nativeBuildInputs = [
    cmake
  ];

  propagatedBuildInputs = [
    tbb_2021_8
  ];

  cmakeFlags = [
    "-DCMAKE_CTEST_ARGUMENTS=--exclude-regex;legacy_hipStream_t"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  meta = with lib;{
    homepage = "https://github.com/ROCm-Developer-Tools/HIP-CPU";
    description = "An implementation of HIP that works on CPUs, across OSes";
    license = licenses.mit;
    maintainers = with maintainers; [ nickcao ];
  };
}
