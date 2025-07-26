{
  lib,
  buildPythonPackage,
  fetchPypi,
  oslo-config,
  oslo-i18n,
  oslo-policy,
  oslo-utils,
  oslotest,
  pbr,
  setuptools,
  stestr,
}:

buildPythonPackage rec {
  pname = "oslo-upgradecheck";
  version = "2.5.0";
  pyproject = true;

  src = fetchPypi {
    pname = "oslo_upgradecheck";
    inherit version;
    hash = "sha256-p8OuApD0Wqan9hzSpzYG87YI5gaLVqefC2UkQzD1uPQ=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    oslo-config
    oslo-i18n
    oslo-policy
    oslo-utils
  ];

  nativeCheckInputs = [
    oslotest
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  pythonImportsCheck = [ "oslo_upgradecheck" ];

  meta = with lib; {
    description = "Oslo Upgradecheck library";
    homepage = "https://github.com/openstack/oslo.upgradecheck";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
