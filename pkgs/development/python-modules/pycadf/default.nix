{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fixtures,
  oslo-config,
  oslo-serialization,
  pbr,
  pytestCheckHook,
  setuptools,
  testtools,
}:

buildPythonPackage rec {
  pname = "pycadf";
  version = "4.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "pycadf";
    tag = version;
    hash = "sha256-jIpjOADfZmEX8ev3oBN8FiH41The/8X6SC5WetuLRMo=";
  };

  env.PBR_VERSION = version;

  build-system = [
    setuptools
    pbr
  ];

  dependencies = [
    oslo-config
    oslo-serialization
  ];

  nativeCheckInputs = [
    fixtures
    pytestCheckHook
    testtools
  ];

  pythonImportsCheck = [ "pycadf" ];

  meta = with lib; {
    description = " CADF Python module. Mirror of code maintained at opendev.org. ";
    homepage = "https://github.com/openstack/pycadf";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
