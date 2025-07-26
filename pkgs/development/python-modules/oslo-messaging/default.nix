{
  lib,
  amqp,
  buildPythonPackage,
  cachetools,
  confluent-kafka,
  fetchPypi,
  futurist,
  kombu,
  oslo-context,
  oslo-log,
  oslo-metrics,
  oslo-middleware,
  oslo-serialization,
  oslo-service,
  oslotest,
  pbr,
  pifpaf,
  setuptools,
  stestr,
  testscenarios,
  webob,
}:

buildPythonPackage rec {
  pname = "oslo-messaging";
  version = "17.1.0";
  pyproject = true;

  src = fetchPypi {
    pname = "oslo_messaging";
    inherit version;
    hash = "sha256-hMfg66/tKaMB9qLJymHpF1kj32rwjuXtNqQZ9wcKi9w=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    amqp
    cachetools
    futurist
    kombu
    oslo-context
    oslo-log
    oslo-metrics
    oslo-middleware
    oslo-serialization
    oslo-service
    webob
  ];

  nativeCheckInputs = [
    confluent-kafka
    oslotest
    pifpaf
    stestr
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  pythonImportsCheck = [ "oslo_messaging" ];

  meta = with lib; {
    description = "Oslo Messaging library";
    homepage = "https://github.com/openstack/oslo.messaging";
    license = licenses.asl20;
    mainProgram = "oslo-messaging-send-notification";
    teams = [ teams.openstack ];
  };
}
