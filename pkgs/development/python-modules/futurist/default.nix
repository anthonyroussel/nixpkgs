{
  lib,
  buildPythonPackage,
  debtcollector,
  eventlet,
  fetchPypi,
  oslotest,
  pbr,
  setuptools,
  stestr,
  testscenarios,
}:

buildPythonPackage rec {
  pname = "futurist";
  version = "3.1.1";
  pyproject = true;

  src = fetchPypi {
    pname = "futurist";
    inherit version;
    hash = "sha256-zJXdmkCSOEjjIVcSjrehS3jvMlB7HvgihOy+HDc/7uI=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    debtcollector
  ];

  nativeCheckInputs = [
    eventlet
    oslotest
    stestr
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  pythonImportsCheck = [ "futurist" ];

  meta = with lib; {
    description = "A collection of async functionality and additions from the future";
    homepage = "https://github.com/openstack/futurist";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
