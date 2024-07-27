{
  lib,
  buildPythonPackage,
  cliff,
  fetchFromGitea,
  keystoneauth1,
  openstackdocstheme,
  osprofiler,
  osc-lib,
  oslo-i18n,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  pythonOlder,
  pyyaml,
  requests-mock,
  requests,
  setuptools,
  sphinxcontrib-apidoc,
  sphinxHook,
  stevedore,
  stestr,
}:

buildPythonPackage rec {
  pname = "python-mistralclient";
  version = "5.2.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitea {
    domain = "opendev.org";
    owner = "openstack";
    repo = "python-mistralclient";
    rev = version;
    hash = "sha256-Agb1o2MmhlJZPGjGblDbjcHbgjNZtarF+nIJLAfP208=";
  };

  env.PBR_VERSION = version;

  build-system = [
    openstackdocstheme
    pbr
    setuptools
    sphinxcontrib-apidoc
    sphinxHook
  ];

  sphinxBuilders = [ "man" ];

  dependencies = [
    cliff
    keystoneauth1
    osc-lib
    oslo-i18n
    oslo-serialization
    oslo-utils
    pyyaml
    requests
    stevedore
  ];

  doCheck = true;

  nativeCheckInputs = [
    requests-mock
    oslotest
    osprofiler
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  pythonImportsCheck = [ "mistralclient" ];

  meta = {
    homepage = "https://opendev.org/openstack/python-mistralclient";
    description = "Client library for OpenStack Mistral API";
    license = lib.licenses.asl20;
    mainProgram = "mistral";
    maintainers = lib.teams.openstack.members;
  };
}
