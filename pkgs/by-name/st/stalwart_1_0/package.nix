{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  aws-lc,
  bzip2,
  rust-jemalloc-sys-unprefixed,
  sqlite,
  foundationdb,
  zstd,
  stdenv,
  _experimental-update-script-combinators,
  nix-update-script,
  rocksdb_11_8,
  callPackage,
  withFoundationdb ? false,
  stalwartEnterprise ? false,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stalwart" + (lib.optionalString stalwartEnterprise "-enterprise");
  version = "1.0.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "stalwart";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4NUb6Peivb5yG4jZSKUSwYijoF4JTvw4+u2uvN4tGqU=";
  };

  cargoHash = "sha256-QOdPdcCa5HxckfMiNkgnkGMuOlRGIfMMylQs7QUGI5Q=";

  env = {
    ROCKSDB_INCLUDE_DIR = "${rocksdb_11_8}/include";
    ROCKSDB_LIB_DIR = "${rocksdb_11_8}/lib";
  }
  //
    lib.optionalAttrs
      (stdenv.hostPlatform.isLinux && (stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isArmv7))
      {
        # Required to fix Stalwart on ARM systems with 16 KB page size.
        JEMALLOC_SYS_WITH_LG_PAGE = 16;
      };

  # for jieba-rs's include-flate proc macro
  depsBuildBuild = [
    pkg-config
    zstd
  ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    aws-lc
    bzip2
    rust-jemalloc-sys-unprefixed
    sqlite
    zstd
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && withFoundationdb) [ foundationdb ];

  # Issue: https://github.com/stalwartlabs/stalwart/issues/1104
  buildNoDefaultFeatures = true;
  buildFeatures = [
    "sqlite"
    "postgres"
    "mysql"
    "rocks"
    "s3"
    "redis"
    "azure"
    "nats"
  ]
  ++ lib.optionals withFoundationdb [ "foundationdb" ]
  ++ lib.optionals stalwartEnterprise [ "enterprise" ];

  cargoBuildFlags = [
    "-p"
    "stalwart"
  ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  # Since 0.16.27 -> 1.0.0, tests have been deleted from upstream and only accessible in a private repository [1].
  # Therefore, removing all code related to setting up test infra to clean up module, and disable doCheck.
  #  [1] https://stalw.art/blog/protecting-stalwart/
  doCheck = false;

  postInstall = ''
    mkdir -p $out/etc/stalwart

    mkdir -p $out/lib/systemd/system

    substitute resources/systemd/stalwart-mail.service $out/lib/systemd/system/stalwart.service \
      --replace-fail "__PATH__" "$out"
  '';

  passthru = {
    rocksdb = rocksdb_11_8; # make used rocksdb version available (e.g., for backup scripts)
    webui = callPackage ./webui.nix { };
    spam-filter = callPackage ./spam-filter.nix { };
    # subpackages have distinct version numbers, so we can't use nix-update's `--subpackage`
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { })
      (nix-update-script { attrPath = "stalwart_1_0.webui"; })
      (nix-update-script { attrPath = "stalwart_1_0.spam-filter"; })
    ];
  };

  meta = {
    description = "Secure, modern, all-in-one mail and collaboration server";
    longDescription = ''
      Secure, scalable and fluent in every protocol (IMAP, JMAP, SMTP, CalDAV, CardDAV, WebDAV).
    '';
    homepage = "https://github.com/stalwartlabs/stalwart";
    changelog = "https://github.com/stalwartlabs/stalwart/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = [
      lib.licenses.agpl3Only
    ]
    ++ lib.optionals stalwartEnterprise [
      lib.licenses.stalwart
    ];
    maxSilent = 14400; # 4 hours
    mainProgram = "stalwart";
    maintainers = with lib.maintainers; [
      happysalada
      onny
      oddlama
      pandapip1
      norpol
      debtquity
    ];
  };
})
