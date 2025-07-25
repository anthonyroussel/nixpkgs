{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  noto-fonts-color-emoji,
  dpkg,
  libarchive,
  asar,
  rsync,
  python3,
  buildPackages,
  nixosTests,
  gtk3,
  atk,
  at-spi2-atk,
  cairo,
  pango,
  pipewire,
  gdk-pixbuf,
  glib,
  freetype,
  fontconfig,
  dbus,
  libX11,
  xorg,
  libXi,
  libXcursor,
  libXdamage,
  libXrandr,
  libXcomposite,
  libXext,
  libXfixes,
  libXrender,
  libXtst,
  libXScrnSaver,
  nss,
  nspr,
  alsa-lib,
  cups,
  expat,
  libuuid,
  at-spi2-core,
  libappindicator-gtk3,
  libgbm,
  libwebp,
  # Runtime dependencies:
  systemd,
  libnotify,
  libdbusmenu,
  libpulseaudio,
  xdg-utils,
  wayland,

  # command line arguments which are always set e.g "--password-store=kwallet6"
  commandLineArgs,
}:

{
  pname,
  libdir,
  bindir,
  extractPkg,
  version,
  hash,
  url,
}:

let
  inherit (stdenv) targetPlatform;
  ARCH = if targetPlatform.isAarch64 then "arm64" else "x64";

  # Noto Color Emoji PNG files for emoji replacement; see below.
  noto-fonts-color-emoji-png = noto-fonts-color-emoji.overrideAttrs (prevAttrs: {
    pname = "noto-fonts-color-emoji-png";

    # The build produces 136×128 PNGs by default for arcane font
    # reasons, but we want square PNGs.
    buildFlags = prevAttrs.buildFlags or [ ] ++ [ "BODY_DIMENSIONS=128x128" ];

    makeTargets = [ "compressed" ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      mv build/compressed_pngs $out/share/noto-fonts-color-emoji-png
      python3 add_aliases.py --srcdir=$out/share/noto-fonts-color-emoji-png

      runHook postInstall
    '';
  });

  noto-emoji-sheet-32 = fetchurl {
    url = "https://raw.githubusercontent.com/iamcal/emoji-data/refs/tags/v15.1.2/sheet_google_32.png";
    hash = "sha256-S03NCTbvB5yeQl62WpLNjNGhjNErtgaOB6tAj/X8vPc=";
  };
  noto-emoji-sheet-64 = fetchurl {
    url = "https://raw.githubusercontent.com/iamcal/emoji-data/refs/tags/v15.1.2/sheet_google_64.png";
    hash = "sha256-kZYStR5xAuausSpOD6wJZRJZ1K6nPpweE3aYSgWntS4=";
  };
in
stdenv.mkDerivation rec {
  inherit pname version;

  # Please backport all updates to the stable channel.
  # All releases have a limited lifetime and "expire" 90 days after the release.
  # When releases "expire" the application becomes unusable until an update is
  # applied. The expiration date for the current release can be extracted with:
  # $ grep -a "^{\"buildExpiration" "${signal-desktop}/lib/${dir}/resources/app.asar"
  # (Alternatively we could try to patch the asar archive, but that requires a
  # few additional steps and might not be the best idea.)

  src = fetchurl {
    inherit url hash;
    recursiveHash = true;
    downloadToTemp = true;
    nativeBuildInputs = [
      (if ARCH == "x64" then dpkg else libarchive)
      asar
    ];
    # Signal ships the Apple emoji set without a licence via an npm
    # package and upstream does not seem terribly interested in fixing
    # this; see:
    #
    # * <https://github.com/signalapp/Signal-Android/issues/5862>
    # * <https://whispersystems.discoursehosting.net/t/signal-is-likely-violating-apple-license-terms-by-using-apple-emoji-in-the-sticker-creator-and-android-and-desktop-apps/52883>
    #
    # We work around this by replacing it with the Noto Color Emoji
    # set, which is available under a FOSS licence and more likely to
    # be used on a NixOS machine anyway. The Apple emoji are removed
    # during `fetchurl` to ensure that the build doesn’t cache the
    # unlicensed emoji files, but the rest of the work is done in the
    # main derivation.
    postFetch = ''
      ${extractPkg}
      asar extract "$out/${libdir}/resources/app.asar" $out/asar-contents
      rm -r \
        "$out/${libdir}/resources/app.asar"{,.unpacked} \
        $out/asar-contents/images/emoji-sheet-32.webp \
        $out/asar-contents/images/emoji-sheet-64.webp
    '';
  };

  nativeBuildInputs = [
    rsync
    asar
    python3
    autoPatchelfHook
    # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
    # Has to use `makeShellWrapper` from `buildPackages` even though `makeShellWrapper` from the inputs is spliced because `propagatedBuildInputs` would pick the wrong one because of a different offset.
    (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
    libwebp
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libappindicator-gtk3
    libpulseaudio
    libnotify
    libuuid
    libgbm
    nspr
    nss
    pango
    systemd
    xorg.libxcb
    xorg.libxshmfence
  ];

  runtimeDependencies = [
    (lib.getLib systemd)
    libappindicator-gtk3
    libnotify
    libdbusmenu
    pipewire
    xdg-utils
    wayland
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    rsync -a --chmod=+w $src/ .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib

    mv usr/share $out/share
    mv "${libdir}" "$out/lib/signal-desktop"

    # Symlink to bin
    mkdir -p $out/bin
    ln -s "$out/lib/signal-desktop/signal-desktop" $out/bin/${meta.mainProgram}

    # Create required symlinks:
    ln -s libGLESv2.so "$out/lib/signal-desktop/libGLESv2.so.2"

    # Compress the emoji sheets to webp, as signal expects webp images. The flags used are the same as those used upstream.
    cwebp -progress -mt -preset icon -alpha_filter best -alpha_q 20 -pass 10 -q 75 ${noto-emoji-sheet-32} -o asar-contents/images/emoji-sheet-32.webp
    cwebp -progress -mt -preset icon -alpha_filter best -alpha_q 20 -pass 10 -q 75 ${noto-emoji-sheet-64} -o asar-contents/images/emoji-sheet-64.webp

    # Copy the Noto Color Emoji PNGs into the ASAR contents. See `src`
    # for the motivation, and the script for the technical details.
    emojiPrefix=$(
      python3 ${./copy-noto-emoji.py} \
      ${noto-fonts-color-emoji-png}/share/noto-fonts-color-emoji-png \
      asar-contents
    )

    # Replace the URL used for fetching large versions of emoji with
    # the local path to our copied PNGs.
    substituteInPlace asar-contents/preload.bundle.js \
      --replace-fail \
        'emoji://jumbo?emoji=' \
        "file://$out/lib/signal-desktop/resources/app.asar/$emojiPrefix/"

    # `asar(1)` copies files from the corresponding `.unpacked`
    # directory when extracting, and will put them back in the modified
    # archive if you don’t specify them again when repacking. Signal
    # leaves their native `.node` libraries unpacked, so we match that.
    asar pack \
      --unpack '*.node' \
      asar-contents \
      "$out/lib/signal-desktop/resources/app.asar"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
      --add-flags ${lib.escapeShellArg commandLineArgs}
    )

    # Fix the desktop link
    substituteInPlace $out/share/applications/signal-desktop.desktop \
      --replace-fail "/${bindir}/signal-desktop" ${meta.mainProgram} \
      --replace-fail "StartupWMClass=Signal" "StartupWMClass=signal"

    mv $out/share/applications/signal{-desktop,}.desktop

    # Note: The following path contains bundled libraries:
    # $out/lib/signal-desktop/resources/app.asar.unpacked/node_modules/
    patchelf --add-needed ${libpulseaudio}/lib/libpulse.so "$out/lib/signal-desktop/resources/app.asar.unpacked/node_modules/@signalapp/ringrtc/build/linux/libringrtc-${ARCH}.node"
  '';

  passthru = {
    # Tests if the application launches and waits for "Link your phone to Signal Desktop":
    tests.application-launch = nixosTests.signal-desktop;
    updateScript.command = [ ./update.sh ];
  };

  meta = {
    description = "Private, simple, and secure messenger";
    longDescription = ''
      Signal Desktop is an Electron application that links with your
      "Signal Android" or "Signal iOS" app.
    '';
    homepage = "https://signal.org/";
    changelog = "https://github.com/signalapp/Signal-Desktop/releases/tag/v${version}";
    license = [
      lib.licenses.agpl3Only

      # Various npm packages
      lib.licenses.free

      lib.licenses.asl20 # noto-emoji
      lib.licenses.mit # emoji-data
    ];
    maintainers = with lib.maintainers; [
      mic92
      equirosa
      urandom
      bkchr
      emily
      Gliczy
    ];
    mainProgram = "signal-desktop";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
