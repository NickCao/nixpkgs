{ qtModule
, lib
, stdenv
, qtbase
, qtdeclarative
, qtquick3d
, qtshadertools
, qtsvg
, pkg-config
, alsa-lib
, ffmpeg
, gstreamer
, gst-plugins-base
, libpulseaudio
, wayland
, elfutils
, libunwind
, orc
, libva
}:

qtModule {
  pname = "qtmultimedia";
  qtInputs = [
    qtbase
    qtdeclarative
    qtquick3d
    qtsvg
    qtshadertools
  ];
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    ffmpeg
    gstreamer
    gst-plugins-base
    libpulseaudio
    elfutils
    libunwind
    alsa-lib
    wayland
    orc
    libva
  ];
}
