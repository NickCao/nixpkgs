{
  lib,
  python3,
  fetchPypi,
  fetchFromGitHub,
  withE2BE ? true,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {
      tulir-telethon = self.telethon.overridePythonAttrs (oldAttrs: rec {
        version = "1.99.0a4";
        pname = "tulir-telethon";
        src = fetchPypi {
          pname = "tulir_telethon";
          inherit version;
          hash = "sha256-9OOgLE6FN5WJzscsq7b15IDeGfId+krc0PUequx5GY0=";
        };
        doCheck = false;
      });
    };
  };
in
python.pkgs.buildPythonPackage {
  pname = "mautrix-telegram";
  version = "0.15.2-unstable-2025-04-19";
  disabled = python.pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    rev = "530bd9e52e15c0fe4237756cd7880f4fafa8ddf1";
    hash = "sha256-LBThtncYAT83JcryIaWhjak1HZf7VGnoI/W9JIYTcRQ=";
  };

  format = "setuptools";

  patches = [ ./0001-Re-add-entrypoint.patch ];

  propagatedBuildInputs =
    with python.pkgs;
    (
      [
        ruamel-yaml
        python-magic
        commonmark
        aiohttp
        yarl
        (mautrix.override { withOlm = withE2BE; })
        tulir-telethon
        asyncpg
        mako
        setuptools
        # speedups
        cryptg
        aiodns
        brotli
        # qr_login
        pillow
        qrcode
        # formattednumbers
        phonenumbers
        # metrics
        prometheus-client
        # sqlite
        aiosqlite
        # proxy support
        pysocks
      ]
      ++ lib.optionals withE2BE [
        # e2be
        python-olm
        pycryptodome
        unpaddedbase64
      ]
    );

  # has no tests
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/mautrix/telegram";
    description = "Matrix-Telegram hybrid puppeting/relaybot bridge";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      nyanloutre
      ma27
      nickcao
    ];
    mainProgram = "mautrix-telegram";
  };
}
