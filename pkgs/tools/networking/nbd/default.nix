{ lib
, stdenv
, fetchurl
, fetchpatch2
, pkg-config
, glib
, which
, bison
, nixosTests
, libnl
, linuxHeaders
, gnutls
}:

stdenv.mkDerivation rec {
  pname = "nbd";
  version = "3.25";

  src = fetchurl {
    url = "https://github.com/NetworkBlockDevice/nbd/releases/download/nbd-${version}/nbd-${version}.tar.xz";
    hash = "sha256-9cj9D8tXsckmWU0OV/NWQy7ghni+8dQNCI8IMPDL3Qo=";
  };

  patches = [
    # fix port setting from nbdtab
    # https://github.com/NetworkBlockDevice/nbd/pull/154
    (fetchpatch2 {
      url = "https://github.com/NetworkBlockDevice/nbd/commit/c9f38fcc468c8cddeeb476328fbd5a16afe9ad07.patch";
      hash = "sha256-1TbXcZtL0XdQ6Fcc3sA4gzcaL6aN9+9LjMUGK5PGiU4=";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    which
    bison
  ];

  buildInputs = [
    glib
    gnutls
  ] ++ lib.optionals stdenv.isLinux [
    libnl
    linuxHeaders
  ];

  configureFlags = [
    "--sysconfdir=/etc"
  ];

  doCheck = !stdenv.isDarwin;

  passthru.tests = {
    test = nixosTests.nbd;
  };

  meta = {
    homepage = "https://nbd.sourceforge.io/";
    description = "Map arbitrary files as block devices over the network";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
