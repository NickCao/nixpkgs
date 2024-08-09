{ lib
, stdenv
, substituteAll
, fetchFromGitHub
, autoreconfHook
, gettext
, makeWrapper
, pkg-config
, vala
, wrapGAppsHook3
, dbus
, systemd
, dconf ? null
, glib
, gdk-pixbuf
, gobject-introspection
, gtk3
, gtk4
, gtk-doc
, libdbusmenu-gtk3
, runCommand
, isocodes
, cldr-annotations
, unicode-character-database
, unicode-emoji
, python3
, json-glib
, libnotify ? null
, enableUI ? stdenv.buildPlatform.canExecute stdenv.hostPlatform
, withWayland ? true
, libxkbcommon
, wayland
, buildPackages
, runtimeShell
, nixosTests
}:

let
  python3Runtime = python3.withPackages (ps: with ps; [ pygobject3 ]);
  # make-dconf-override-db.sh needs to execute dbus-launch in the sandbox,
  # it will fail to read /etc/dbus-1/session.conf unless we add this flag
  dbus-launch = runCommand "sandbox-dbus-launch"
    {
      nativeBuildInputs = [ makeWrapper ];
    } ''
    makeWrapper ${dbus}/bin/dbus-launch $out/bin/dbus-launch \
      --add-flags --config-file=${dbus}/share/dbus-1/session.conf
  '';
in

stdenv.mkDerivation rec {
  pname = "ibus";
  version = "1.5.30";

  src = fetchFromGitHub {
    owner = "ibus";
    repo = "ibus";
    rev = version;
    sha256 = "sha256-VgSjeKF9DCkDfE9lHEaWpgZb6ibdgoDf/I6qeJf8Ah4=";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      pythonInterpreter = python3Runtime.interpreter;
      pythonSitePackages = python3.sitePackages;
    })
    ./build-without-dbus-launch.patch
  ];

  outputs = [ "out" "dev" "installedTests" ];

  postPatch = ''
    # Maintainer does not want to create separate tarballs for final release candidate and release versions,
    # so we need to set `ibus_released` to `1` in `configure.ac`. Otherwise, anyone running `ibus version` gets
    # a version with an inaccurate `-rcX` suffix.
    # https://github.com/ibus/ibus/issues/2584
    substituteInPlace configure.ac --replace "m4_define([ibus_released], [0])" "m4_define([ibus_released], [1])"

    patchShebangs --build data/dconf/make-dconf-override-db.sh
    cp ${buildPackages.gtk-doc}/share/gtk-doc/data/gtk-doc.make .
    substituteInPlace bus/services/org.freedesktop.IBus.session.GNOME.service.in --replace "ExecStart=sh" "ExecStart=${runtimeShell}"
    substituteInPlace bus/services/org.freedesktop.IBus.session.generic.service.in --replace "ExecStart=sh" "ExecStart=${runtimeShell}"
  '' + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace tools/Makefile.am \
      --replace "bin_PROGRAMS = ibus" ""
  '';

  preAutoreconf = "touch ChangeLog";

  configureFlags = [
    # The `AX_PROG_{CC,CXX}_FOR_BUILD` autoconf macros can pick up unwrapped GCC binaries,
    # so we set `{CC,CXX}_FOR_BUILD` to override that behavior.
    # https://github.com/NixOS/nixpkgs/issues/21751
    "CC_FOR_BUILD=${buildPackages.stdenv.cc}/bin/cc"
    "CXX_FOR_BUILD=${buildPackages.stdenv.cc}/bin/c++"
    "GLIB_COMPILE_RESOURCES=${buildPackages.glib.dev}/bin/glib-compile-resources"
    "--disable-memconf"
    (lib.enableFeature (dconf != null) "dconf")
    (lib.enableFeature (libnotify != null) "libnotify")
    (lib.enableFeature withWayland "wayland")
    (lib.enableFeature enableUI "ui")
    "--disable-gtk2"
    "--enable-gtk4"
    "--enable-install-tests"
    "--with-unicode-emoji-dir=${unicode-emoji}/share/unicode/emoji"
    "--with-emoji-annotation-dir=${cldr-annotations}/share/unicode/cldr/common/annotations"
    "--with-ucd-dir=${unicode-character-database}/share/unicode"
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "--disable-vala"
    "--disable-engine"
  ];

  makeFlags = [
    "test_execsdir=${placeholder "installedTests"}/libexec/installed-tests/ibus"
    "test_sourcesdir=${placeholder "installedTests"}/share/installed-tests/ibus"
  ];

  strictDeps = true;

  depsBuildBuild = [
    buildPackages.stdenv.cc
    pkg-config
  ];

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    gettext
    makeWrapper
    pkg-config
    python3
    vala
    wrapGAppsHook3
    dbus-launch
    gobject-introspection
    glib
  ];

  propagatedBuildInputs = [
    glib
  ];

  buildInputs = [
    dbus
    systemd
    dconf
    gdk-pixbuf
    python3.pkgs.pygobject3 # for pygobject overrides
    gtk3
    gtk4
    isocodes
    json-glib
    libnotify
    libdbusmenu-gtk3
  ] ++ lib.optionals withWayland [
    libxkbcommon
    wayland
  ];

  enableParallelBuilding = true;

  doCheck = false; # requires X11 daemon
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/ibus version
  '';

  postInstall = ''
    # It has some hardcoded FHS paths and also we do not use it
    # since we set up the environment in NixOS tests anyway.
    moveToOutput "bin/ibus-desktop-testing-runner" "$installedTests"
  '';

  postFixup = ''
    # set necessary environment also for tests
    for f in $installedTests/libexec/installed-tests/ibus/*; do
        wrapGApp $f
    done
  '';

  passthru = {
    tests = {
      installed-tests = nixosTests.installed-tests.ibus;
    };
  };

  meta = with lib; {
    homepage = "https://github.com/ibus/ibus";
    description = "Intelligent Input Bus, input method framework";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ttuegel ];
  };
}
