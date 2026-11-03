{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  aws-c-common,
  nix,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aws-c-cal";
  # nixpkgs-update: no auto update
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "aws-c-cal";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7oKJcvoMpHVsajVkBYkAypBn1IXsddylN9Sq9KDYLwM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    aws-c-common
    openssl
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # The OS crypto libraries lack ed25519 on darwin, use libcrypto for it
    (lib.cmakeBool "AWS_USE_LIBCRYPTO_TO_SUPPORT_ED25519_EVERYWHERE" true)
  ];

  passthru.tests = {
    inherit nix;
  };

  meta = {
    description = "AWS Crypto Abstraction Layer";
    homepage = "https://github.com/awslabs/aws-c-cal";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = [ ];
  };
})
