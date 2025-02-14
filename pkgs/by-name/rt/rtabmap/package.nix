{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,

  # nativeBuildInputs
  cmake,
  libsForQt5,
  pkg-config,
  wrapGAppsHook3,

  # buildInputs
  opencv,
  pcl,
  liblapack,
  xorg,
  libusb1,
  eigen,
  g2o,
  ceres-solver,
  octomap,
  freenect,
  libdc1394,
  libGL,
  libGLU,
  vtkWithQt5,
  zed-open-capture,
  hidapi,

  # passthru
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtabmap";
  version = "0.21.4.1";

  src = fetchFromGitHub {
    owner = "introlab";
    repo = "rtabmap";
    tag = finalAttrs.version;
    hash = "sha256-y/p1uFSxVQNXO383DLGCg4eWW7iu1esqpWlyPMF3huk=";
  };

  patches = [
    # [BUILD] SensorCaptureThread.cpp <pcl/io/io.h> deprecated on newer PCL versions
    # https://github.com/introlab/rtabmap/issues/1388
    (fetchpatch2 {
      url = "https://github.com/introlab/rtabmap/commit/cbd3995b600fc2acc4cb57b81f132288a6c91188.patch";
      hash = "sha256-G66SMHGvrHNqST9nusC1I7HBzzCRVWcTL3/IgfKM1cM=";
    })
  ];

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    ## Required
    opencv
    opencv.cxxdev
    pcl
    liblapack
    xorg.libSM
    xorg.libICE
    xorg.libXt
    ## Optional
    libusb1
    eigen
    g2o
    ceres-solver
    # libpointmatcher - ABI mismatch
    octomap
    freenect
    libdc1394
    # librealsense - missing includedir
    libsForQt5.qtbase
    libGL
    libGLU
    vtkWithQt5
    zed-open-capture
    hidapi
  ];

  # Disable warnings that are irrelevant to us as packagers
  cmakeFlags = [ "-Wno-dev" ];

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Real-Time Appearance-Based 3D Mapping";
    homepage = "https://introlab.github.io/rtabmap/";
    changelog = "https://github.com/introlab/rtabmap/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = with lib.platforms; linux;
  };
})
