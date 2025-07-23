{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libacars,
  rtl-sdr,
}:

stdenv.mkDerivation {
  pname = "vdlm2dec";
  version = "2.3-unstable-2023-06-21";

  src = fetchFromGitHub {
    owner = "TLeconte";
    repo = "vdlm2dec";
    rev = "b47873dca7b20584db3cbef646f2d09f450cf071";
    hash = "sha256-SN+Pxgylg3rszhsbbieP5eQsjWpngVbaIxTWaekCKWA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libacars
    rtl-sdr
  ];

  cmakeFlags = [
    (lib.cmakeBool "rtl" true)
  ];

  meta = {
    description = "Vdl mode 2 SDR decoder";
    homepage = "https://github.com/TLeconte/vdlm2dec";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "vdlm2dec";
    platforms = lib.platforms.linux;
  };
}
