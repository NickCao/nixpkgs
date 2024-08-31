{
  stdenv,
  lib,
  fetchFromGitLab,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  desktop-file-utils,
  gettext,
  itstool,
  libxml2,
  python3,
  wrapGAppsHook3,
  gtk3,
  glib,
  libsoup,
  gnome-online-accounts,
  librest,
  json-glib,
  gnome-autoar,
  gspell,
  libcanberra,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "gnome-recipes";
  version = "2.0.4";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "recipes";
    rev = version;
    fetchSubmodules = true;
    sha256 = "GyFOwEYmipQdFLtTXn7+NvhDTzxBlOAghr3cZT4QpQw=";
  };

  strictDeps = true;

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs =
    [
      meson
      ninja
      pkg-config
      glib
      desktop-file-utils
      gettext
      itstool
      libxml2 # xmllint
      python3
      gtk3 # gtk-update-icon-cache
      wrapGAppsHook3
    ]
    ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
      mesonEmulatorHook
    ];

  buildInputs = [
    gtk3
    glib
    libsoup
    gnome-online-accounts
    librest
    json-glib
    gnome-autoar
    gspell
    libcanberra
  ];

  postPatch = ''
    patchShebangs --build src/list_to_c.py meson_post_install.py
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Recipe management application for GNOME";
    mainProgram = "gnome-recipes";
    homepage = "https://gitlab.gnome.org/GNOME/recipes";
    maintainers = teams.gnome.members;
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
