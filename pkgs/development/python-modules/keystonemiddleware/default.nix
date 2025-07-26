{
  lib,
  buildPythonPackage,
  fetchPypi,
  fixtures,
  keystoneauth1,
  oslo-cache,
  oslo-config,
  oslo-context,
  oslo-i18n,
  oslo-log,
  oslo-messaging,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  pycadf,
  pyjwt,
  pytestCheckHook,
  python-keystoneclient,
  python-memcached,
  requests-mock,
  requests,
  setuptools,
  testresources,
  testtools,
  webob,
  webtest,
}:

buildPythonPackage rec {
  pname = "keystonemiddleware";
  version = "10.11.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-F57eGxAovnWrOOEB4czz8hTr/v8UU4n0Rep4dRqvgOw=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    keystoneauth1
    oslo-cache
    oslo-config
    oslo-context
    oslo-i18n
    oslo-log
    oslo-serialization
    oslo-utils
    pycadf
    pyjwt
    python-keystoneclient
    requests
    webob
  ];

  nativeCheckInputs = [
    fixtures
    oslo-messaging
    oslotest
    pytestCheckHook
    python-memcached
    requests-mock
    testresources
    testtools
    webtest
  ];

  pythonImportsCheck = [ "keystonemiddleware" ];

  meta = {
    description = "Oslo Configuration API";
    homepage = "https://github.com/openstack/keystonemiddleware";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
