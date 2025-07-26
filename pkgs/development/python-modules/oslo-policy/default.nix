{
  lib,
  buildPythonPackage,
  fetchPypi,
  oslo-config,
  oslo-context,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  requests,
  requests-mock,
  setuptools,
  sphinx,
  stestr,
}:

buildPythonPackage rec {
  pname = "oslo-policy";
  version = "4.5.1";
  pyproject = true;

  src = fetchPypi {
    pname = "oslo_policy";
    inherit version;
    hash = "sha256-rr7rPIi3fFZhapcKBY6b8DD0n4LiODpumofAszk60UI=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    requests
    oslo-config
    oslo-context
    oslo-i18n
    oslo-serialization
    oslo-utils
    sphinx
  ];

  nativeCheckInputs = [
    oslotest
    requests-mock
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  pythonImportsCheck = [ "oslo_policy" ];

  meta = with lib; {
    description = "Oslo Policy library";
    homepage = "https://github.com/openstack/oslo.policy";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
