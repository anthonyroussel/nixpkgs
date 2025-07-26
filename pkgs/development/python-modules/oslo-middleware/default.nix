{
  lib,
  buildPythonPackage,
  bcrypt,
  debtcollector,
  fetchPypi,
  jinja2,
  oslo-config,
  oslo-context,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  setuptools,
  statsd,
  stestr,
  stevedore,
  webob,
}:

buildPythonPackage rec {
  pname = "oslo-middleware";
  version = "6.6.0";
  pyproject = true;

  src = fetchPypi {
    pname = "oslo_middleware";
    inherit version;
    hash = "sha256-bMucgPGJ/rxcxQ4RPA6JTJksNpff1v5yL/hPzNtbpSY=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    bcrypt
    debtcollector
    jinja2
    oslo-config
    oslo-context
    oslo-i18n
    oslo-utils
    statsd
    stevedore
    webob
  ];

  doCheck = true;

  nativeCheckInputs = [
    oslo-serialization
    oslotest
    stestr
  ];

  checkPhase = ''
    stestr run
  '';

  pythonImportsCheck = [ "oslo_middleware" ];

  meta = with lib; {
    description = "Oslo Middleware library";
    homepage = "https://github.com/openstack/oslo.middleware";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
