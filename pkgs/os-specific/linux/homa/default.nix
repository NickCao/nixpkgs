{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, kernel
}:

stdenv.mkDerivation {
  pname = "homa";
  version = "unstable-2023-03-07";

  src = fetchFromGitHub {
    owner = "PlatformLab";
    repo = "HomaModule";
    rev = "aae01aa8f62af490cf24c8ed5844fa79942b91ea";
    sha256 = "sha256-PxLGEENV973MEr0ZmVdmAZFO8fv03p28S2A8PWQezYE=";
  };

  patches = [
    # Add install target
    (fetchpatch {
      url = "https://github.com/PlatformLab/HomaModule/commit/cca580fa0a545bfdeca5bcaa170f228f95977816.patch";
      hash = "sha256-Zrpggu9C+oNdC0NEDzOc5khdnGpOrs9QfKwQ1nWhs7w=";
    })
  ];

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "An implementation of the Homa transport protocol";
    homepage = "https://github.com/PlatformLab/HomaModule";
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.nickcao ];
    broken = versionOlder kernel.version "6.0";
  };
}
