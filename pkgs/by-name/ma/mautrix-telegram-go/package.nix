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
  version = "0.15.3-unstable-2026-04-04";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    rev = "0172a5733b53f3b9c2385bacacbfd76614392442";
    hash = "sha256-KLHLkcZmTMQ76t7s7VbsNrbsYoTlZnTXN5ZfyF+S8I8=";
  };

  vendorHash = "sha256-yX+1+us+CuZxZkrQZeC7lUhvO6Zl8ecxkhTs+q9QES4=";

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
