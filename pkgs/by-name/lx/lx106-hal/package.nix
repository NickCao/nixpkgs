{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation {
  pname = "lx106-hal";
  version = "unstable-2016-01-01";

  src = fetchFromGitHub {
    owner = "tommie";
    repo = "lx106-hal";
    rev = "e4bcc63c9c016e4f8848e7e8f512438ca857531d";
    hash = "sha256-DFCOnMCHbCLIc8fJAB6kIeRwO89im/GcasTQ/+tLKt4=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = {
    description = "The libhal part of the SDK";
    homepage = "https://github.com/tommie/lx106-hal";
    license = lib.licenses.mit;
  };
}
