{ lib
, stdenv
, anyio
, buildPythonPackage
, fetchFromGitHub
, hatchling
, httpcore
, httpx
, isPyPy
, python
, pythonOlder
, wsproto
}:

buildPythonPackage rec {
  pname = "httpx-ws";
  version = "0.5.1";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "frankie567";
    repo = "httpx-ws";
    rev = "refs/tags/v${version}";
    hash = "sha256-OYfH9KfcGF3pmpHL2OP2sW3785SQu7ySNk9M329FU40=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace ', "hatch-regex-commit"' "" \
      --replace 'source = "regex_commit"' ""
  '';

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    anyio
    httpcore
    httpx
    wsproto
  ];

  doCheck = false;

  pythonImportsCheck = [
    "httpx_ws"
  ];

  meta = with lib; {
    changelog = "https://github.com/frankie567/httpx-ws/releases/tag/${version}";
    description = "WebSocket support for HTTPX";
    homepage = "https://github.com/frankie567/httpx-ws";
    license = licenses.mit;
    maintainers = with maintainers; [ anthonyroussel ];
  };
}
