{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  unittestCheckHook,
  websockets,
  aws-c-auth,
  aws-c-cal,
  aws-c-common,
  aws-c-compression,
  aws-c-event-stream,
  aws-c-http,
  aws-c-io,
  aws-c-mqtt,
  aws-c-s3,
  aws-c-sdkutils,
  aws-checksums,
  openssl,
  s2n-tls,
}:

buildPythonPackage (finalAttrs: {
  pname = "awscrt";
  version = "0.37.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "aws-crt-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nbCKh/O30XTWspVhsDgFashF9faAEvepQT0Ix5nGIsk=";
  };

  postPatch = ''
    substituteInPlace awscrt/__init__.py \
      --replace-fail "__version__ = '1.0.0.dev0'" "__version__ = '${finalAttrs.version}'"
  '';

  build-system = [ setuptools ];

  buildInputs = [
    aws-c-auth
    aws-c-cal
    aws-c-common
    aws-c-compression
    aws-c-event-stream
    aws-c-http
    aws-c-io
    aws-c-mqtt
    aws-c-s3
    aws-c-sdkutils
    aws-checksums
    openssl
    s2n-tls
  ];

  env.AWS_CRT_BUILD_USE_SYSTEM_LIBS = "1";

  pythonImportsCheck = [ "awscrt" ];

  # Upstream's test harness relies on unittest internals (leak checker)
  nativeCheckInputs = [
    unittestCheckHook
    websockets
  ];

  __darwinAllowLocalNetworking = true;

  # Security.framework (key generation, TLS trust evaluation) needs securityd
  sandboxProfile = ''
    (allow mach-lookup (global-name "com.apple.SecurityServer"))
  '';

  preCheck = ''
    rm -r awscrt

    # Require network access, or a keychain on darwin
    rm test/test_{aiohttp_client,http_client,io,proxy}.py
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    # Require the system trust store: aws-c-io only looks for it in hardcoded
    # paths like /etc/ssl/certs, which don't exist in the sandbox
    rm test/test_{appexit,auth,aws_iot_metrics,s3}.py
  '';

  meta = {
    homepage = "https://github.com/awslabs/aws-crt-python";
    changelog = "https://github.com/awslabs/aws-crt-python/releases/tag/${finalAttrs.src.tag}";
    description = "Python bindings for the AWS Common Runtime";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davegallant ];
  };
})
