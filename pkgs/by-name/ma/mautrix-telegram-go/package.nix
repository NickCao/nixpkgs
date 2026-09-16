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
  version = "0.2609.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M8kQap14MRh3tlqOe7JxLkJlsNsJY/COztv0AqvdgF0=";
  };

  vendorHash = "sha256-qW/v/QmhQRF2SAMUNXE2mfVGVEp+DU3gESWVRKHqfGM=";

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
