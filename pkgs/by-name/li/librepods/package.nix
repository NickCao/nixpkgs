{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libpulseaudio,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librepods";
  version = "0.1.0-unstable-2025-11-24";

  src = fetchFromGitHub {
    owner = "kavishdevar";
    repo = "librepods";
    rev = "345b7b905113f67c9f666a3c4363c293b3a24d23";
    hash = "sha256-zQoF5Ovyt8Nphwwl4MOeDuED0y3EIWOiylQWmA88auM=";
  };

  sourceRoot = "${finalAttrs.src.name}/linux";

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libpulseaudio
    qt6.qtbase
    qt6.qtconnectivity
    qt6.qtmultimedia
  ];

  meta = {
    description = "AirPods liberated from Apple's ecosystem";
    homepage = "https://github.com/kavishdevar/librepods";
    changelog = "https://github.com/kavishdevar/librepods/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "librepods";
    platforms = lib.platforms.linux;
  };
})
