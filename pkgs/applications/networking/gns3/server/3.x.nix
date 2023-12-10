{ channel
, version
, hash
}:

{ lib
, fetchFromGitHub
, gns3-server
, pkgsStatic
, python3
, stdenv
, testers
}:

python3.pkgs.buildPythonApplication {
  pname = "gns3-server";
  pyproject = true;
  inherit version;

  src = fetchFromGitHub {
    inherit hash;
    owner = "GNS3";
    repo = "gns3-server";
    rev = "refs/tags/v${version}";
  };

  nativeBuildInputs = with python3.pkgs; [
    pythonRelaxDepsHook
    setuptools
  ];

  pythonRelaxDeps = [
    "aiohttp"
    "aiosqlite"
    "alembic"
    "email-validator"
    "fastapi"
    "psutil"
    "python-multipart"
    "sentry-sdk"
    "sqlalchemy"
    "uvicorn"
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiofiles
    aiohttp
    aiosqlite
    alembic
    async-timeout
    distro
    email-validator
    fastapi
    jinja2
    passlib
    passlib.optional-dependencies.bcrypt
    platformdirs
    psutil
    py-cpuinfo
    pydantic
    python-jose
    python-multipart
    sentry-sdk
    sqlalchemy
    uvicorn
    watchfiles
    websockets
    zstandard
  ] ++ lib.optionals (pythonAtLeast "3.10") [
    truststore
  ] ++ lib.optionals (pythonOlder "3.9") [
    importlib-resources
  ];

  doCheck = true;

  # Otherwise tests will fail to create directory
  # Permission denied: '/homeless-shelter'
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  checkInputs = with python3.pkgs; [
    httpx
    httpx-ws
    pytest-asyncio_0_21
    pytest-timeout
    pytestCheckHook
  ];

  passthru.tests.version = testers.testVersion {
    package = gns3-server;
    command = "${lib.getExe gns3-server} --version";
  };

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "Graphical Network Simulator 3 server (${channel} release)";
    longDescription = ''
      The GNS3 server manages emulators such as Dynamips, VirtualBox or
      Qemu/KVM. Clients like the GNS3 GUI control the server using a HTTP REST
      API.
    '';
    homepage = "https://www.gns3.com/";
    changelog = "https://github.com/GNS3/gns3-server/releases/tag/v${version}";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ anthonyroussel ];
    mainProgram = "gns3server";
  };
}
