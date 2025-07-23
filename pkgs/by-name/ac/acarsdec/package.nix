{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libacars,
  paho-mqtt-c,
  libsndfile,
  rtl-sdr,
  withRtl ? true,
}:

stdenv.mkDerivation {
  pname = "acarsdec";
  version = "3.7-unstable-2023-04-08";

  src = fetchFromGitHub {
    owner = "TLeconte";
    repo = "acarsdec";
    rev = "7920079b8e005c6c798bd478a513211daf9bbd25";
    hash = "sha256-SE8amDCtyJlqMMoGOoT80t3Ponws1VDTt/e7HpDdmXI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libacars
    paho-mqtt-c
    libsndfile
  ]
  ++ lib.optional withRtl rtl-sdr;

  cmakeFlags = [
    (lib.cmakeBool "rtl" withRtl)
  ];

  meta = {
    description = "ACARS SDR decoder";
    homepage = "https://github.com/TLeconte/acarsdec";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "acarsdec";
    platforms = lib.platforms.linux;
  };
}
