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
  version = "0.1.0-unstable-2025-11-17";

  src = fetchFromGitHub {
    owner = "kavishdevar";
    repo = "librepods";
    rev = "938f0d5448aeeb2de95207ec165fd587d0d23512";
    hash = "sha256-vWtBSHYPtrSmYzY25a1RcVUlpaXF2WzNLke7RiST/38=";
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
