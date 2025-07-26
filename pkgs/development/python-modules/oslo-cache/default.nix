{
  lib,
  buildPythonPackage,
  dogpile-cache,
  fetchPypi,
  oslo-log,
  oslotest,
  pbr,
  pymemcache,
  pymongo,
  python-binary-memcached,
  python-memcached,
  redis,
  setuptools,
  stestr,
}:

buildPythonPackage rec {
  pname = "oslo-cache";
  version = "3.11.0";
  pyproject = true;

  src = fetchPypi {
    pname = "oslo_cache";
    inherit version;
    hash = "sha256-BebSYzC4YaWWw0xwBZMghqH9SShAUr2LUFUSHVR+Z7E=";
  };

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    dogpile-cache
    # dogpile-cache.optional-dependencies.bmemcached
    oslo-log
    # bmemcached # not in requirements.txt, check check
  ];

  optional-dependencies = {
    dogpile = [
      python-memcached
      pymemcache
      python-binary-memcached
      redis
    ];
    mongo = [
      pymongo
    ];
  };

  nativeCheckInputs = [
    oslotest
    stestr
  ] ++ optional-dependencies.mongo
    ++ optional-dependencies.dogpile;

  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "oslo_db.tests.sqlalchemy.test_utils.TestModelQuery.test_project_filter_allow_none")
    runHook postCheck
  '';

  pythonImportsCheck = [ "oslo_cache" ];

  meta = with lib; {
    description = "Oslo Database library";
    homepage = "https://github.com/openstack/oslo.cache";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
