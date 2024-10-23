{
  lib,
  stdenv,
  ApplicationServices,
  docbook-xsl-nons,
  expat,
  fetchFromGitHub,
  Foundation,
  glib,
  gobject-introspection,
  gtk-doc,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,

  # Optional dependencies
  cfitsio,
  cgif,
  fftw,
  imagemagick,
  lcms2,
  libarchive,
  libexif,
  libheif,
  libhwy,
  libimagequant,
  libjpeg,
  libjxl,
  librsvg,
  libspng,
  libtiff,
  libwebp,
  matio,
  openexr,
  openjpeg,
  openslide,
  pango,
  poppler,

  # passthru
  testers,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vips";
  version = "8.15.3";

  outputs = [
    "bin"
    "out"
    "man"
    "dev"
  ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ "devdoc" ];

  src = fetchFromGitHub {
    owner = "libvips";
    repo = "libvips";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-VQtHHitEpxv63wC41TtRWLLCKHDAK7fbrS+cByeWxT0=";
    # Remove unicode file names which leads to different checksums on HFS+
    # vs. other filesystems because of unicode normalisation.
    postFetch = ''
      rm -r $out/test/test-suite/images/
    '';
  };

  nativeBuildInputs =
    [
      docbook-xsl-nons
      gobject-introspection
      meson
      ninja
      pkg-config
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      gtk-doc
    ];

  buildInputs =
    [
      expat
      glib
      libxml2
      (python3.withPackages (p: [ p.pycairo ]))
      # Optional dependencies
      cfitsio
      cgif
      fftw
      imagemagick
      lcms2
      libarchive
      libexif
      libheif
      libhwy
      libimagequant
      libjpeg
      libjxl
      librsvg
      libspng
      libtiff
      libwebp
      matio
      openexr
      openjpeg
      openslide
      pango
      poppler
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ApplicationServices
      Foundation
    ];

  # Required by .pc file
  propagatedBuildInputs = [
    glib
  ];

  mesonFlags =
    [
      "-Dpdfium=disabled"
      "-Dnifti=disabled"
    ]
    ++ lib.optional (!stdenv.hostPlatform.isDarwin) "-Dgtk_doc=true"
    ++ lib.optional (imagemagick == null) "-Dmagick=disabled";

  passthru = {
    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
      version = testers.testVersion {
        package = finalAttrs.finalPackage;
        command = "vips --version";
      };
    };
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v([0-9.]+)"
      ];
    };
  };

  meta = with lib; {
    changelog = "https://github.com/libvips/libvips/blob/${finalAttrs.src.rev}/ChangeLog";
    homepage = "https://www.libvips.org/";
    description = "Image processing system for large images";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      kovirobi
      anthonyroussel
    ];
    pkgConfigModules = [
      "vips"
      "vips-cpp"
    ];
    platforms = platforms.unix;
    mainProgram = "vips";
  };
})
