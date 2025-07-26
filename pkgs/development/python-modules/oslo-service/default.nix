{
  lib,
  buildPythonPackage,
  cotyledon,
  eventlet,
  fetchPypi,
  futurist,
  greenlet,
  oslo-concurrency,
  oslo-log,
  oslo-serialization,
  oslotest,
  paste,
  pastedeploy,
  pbr,
  procps,
  routes,
  setuptools,
  stestr,
  yappi,
}:

buildPythonPackage rec {
  pname = "oslo-service";
  version = "4.2.2";
  pyproject = true;

  src = fetchPypi {
    pname = "oslo_service";
    inherit version;
    hash = "sha256-7kBMO4JY5/W10wL2M+2rVxCOkowYpv2TAtX/0LgvSkI=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    eventlet
    greenlet
    oslo-concurrency
    oslo-log
    pastedeploy
    routes
    paste
    yappi
  ];

  nativeCheckInputs = [
    cotyledon
    oslo-serialization
    procps # required to run ps
    oslotest
    stestr
    futurist
  ];

  # Disable tests that requires networking
  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "
      oslo_service.tests.test_wsgi.TestWSGIServerWithSSL.test_app_using_ipv6_and_ssl
    ")
    runHook postCheck
  '';

  pythonImportsCheck = [ "oslo_service" ];

  meta = with lib; {
    description = "Oslo Service library";
    homepage = "https://github.com/openstack/oslo.service";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
