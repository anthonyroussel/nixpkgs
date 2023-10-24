{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, wrapGAppsHook
, ebook_tools
, freetype
, ghostscript_headless
, git
, gtk3
, libdatrie
, libepoxy
, libpsl
, libpthreadstubs
, libselinux
, libsepol
, libsysprof-capture
, libthai
, libXdmcp
, libxkbcommon
, libxml2
, libxshmfence
, libXtst
, man
, pcre
, pcre2
, poppler
, sqlite
, util-linuxMinimal
, webkitgtk_4_1
, nix-update-script
}:

stdenv.mkDerivation rec {
  version = "0.5.0";
  pname = "apvlv";

  src = fetchFromGitHub {
    owner = "naihe2010";
    repo = "apvlv";
    rev = "refs/tags/v${version}";
    hash = "sha256-iflwIYirazjV8OT+doeCMszLm0OoXsmJkvSXim1tWd8=";
  };

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${poppler.dev}/include/poppler"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    ebook_tools
    freetype
    ghostscript_headless
    git
    gtk3
    libdatrie
    libepoxy
    libpsl
    libpthreadstubs
    libselinux
    libsepol
    libsysprof-capture
    libthai
    libXdmcp
    libxkbcommon
    libxml2
    libxshmfence
    libXtst
    man
    pcre
    pcre2
    poppler
    sqlite
    util-linuxMinimal
    webkitgtk_4_1
  ];

  installPhase = ''
    # binary
    mkdir -p $out/bin
    cp src/apvlv $out/bin/apvlv

    # displays pdfStartup.pdf as default pdf entry
    mkdir -p $out/share/doc/apvlv/
    cp ../Startup.pdf $out/share/doc/apvlv/Startup.pdf
    cp ../main_menubar.glade $out/share/doc/apvlv/main_menubar.glade
  ''
  + lib.optionalString (!stdenv.isDarwin) ''
    install -D ../apvlv.desktop $out/share/applications/apvlv.desktop
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "http://naihe2010.github.io/apvlv/";
    changelog = "https://github.com/naihe2010/apvlv/blob/v${version}/NEWS";
    description = "PDF viewer with Vim-like behaviour";
    longDescription = ''
      apvlv is a PDF/DJVU/UMD/TXT Viewer Under Linux/WIN32
      with Vim-like behaviour.
    '';
    license = licenses.lgpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.ardumont ];
  };
}
