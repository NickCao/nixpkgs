{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  replaceVars,
}:

stdenv.mkDerivation rec {
  pname = "libelfin";
  version = "0.3-unstable-2024-03-11";

  src = fetchFromGitHub {
    owner = "aclements";
    repo = pname;
    rev = "e0172767b79b76373044118ef0272b49b02a0894";
    sha256 = "sha256-xb5/DM2XOFM/w71OwRC/sCRqOSQvxVL1SS2zj2+dD/U=";
  };

  patches = [
    (replaceVars ./0001-Don-t-detect-package-version-with-Git.patch {
      inherit version;
    })
  ];

  nativeBuildInputs = [ python3 ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    homepage = "https://github.com/aclements/libelfin/";
    license = licenses.mit;
    description = "C++11 ELF/DWARF parser";
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
