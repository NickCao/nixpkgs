{
  lib,
  buildGoModule,
  fetchFromGitHub,
  olm,
  # This option enables the use of an experimental pure-Go implementation of the
  # Olm protocol instead of libolm for end-to-end encryption. Using goolm is not
  # recommended by the mautrix developers, but they are interested in people
  # trying it out in non-production-critical environments and reporting any
  # issues they run into.
  withGoolm ? false,
}:

buildGoModule (finalAttrs: {
  pname = "mautrix-telegram-go";
  version = "0.15.3-unstable-2026-04-15";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    rev = "0f0b21b22c68cbb5ef4f140755d82126e146d1bb";
    hash = "sha256-wJPfuqggt5DDF5M8QP9BPzXSG09IdK/sIx/gmuhivFU=";
  };

  vendorHash = "sha256-KmkvmxvTbeV6gXQieXKXXniMfBrLC7xfMBvJP7u4kBE=";

  subPackages = [ "cmd/mautrix-telegram" ];

  buildInputs = lib.optional (!withGoolm) olm;

  tags = lib.optional withGoolm "goolm";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A Matrix-Telegram puppeting bridge";
    homepage = "https://github.com/mautrix/telegram";
    changelog = "https://github.com/mautrix/telegram/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "mautrix-telegram";
  };
})
