{
  lib,
  fetchFromGitHub,
  nixosTests,
  openstack-keystone,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication rec {
  pname = "openstack-keystone";
  version = "27.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "keystone";
    tag = version;
    sha256 = "sha256-TOs/F8C2y3devMQlsASCamx9itqzZbFQ6SOaLEtAwKE=";
  };

  env.PBR_VERSION = version;

  build-system = with python3Packages; [
    pbr
    setuptools
  ];

  dependencies = with python3Packages; [
    bcrypt
    dogpile-cache
    flask
    flask-restful
    jsonschema
    keystonemiddleware
    msgpack
    oauthlib
    oslo-cache
    oslo-config
    oslo-context
    oslo-db
    oslo-i18n
    oslo-log
    oslo-messaging
    oslo-middleware
    oslo-policy
    oslo-serialization
    oslo-upgradecheck
    oslo-utils
    osprofiler
    pycadf
    pyjwt
    pysaml2
    python-keystoneclient
    scrypt
    stevedore
  ];

  optional-dependencies = {
    ldap = with python3Packages; [
      ldappool
      python-ldap
    ];
  };

  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    fixtures
    freezegun
    hacking
    oslotest
    pycodestyle # ignore?
    pytestCheckHook
    testresources
    testscenarios
    testtools
    webtest
  ] ++ optional-dependencies.ldap;

  postInstall = ''
    mkdir -p $out/etc $out/share/doc $out/share/keystone $out/share/httpd

    # install -D httpd $out/share/httpd
    install -D etc/sso_callback_template.html $out/etc/sso_callback_template.html
    install -D etc/logging.conf.sample $out/share/doc/logging.conf.sample
    install -D config-generator/keystone.conf $out/share/keystone/keystone.conf

    # keystone-manager.1.gz man
    # keystone.service
    # /etc/keystone/policy.d/00_default_policy.yaml
  '';

  pythonImportsCheck = [ "keystone" ];

  passthru.tests = {
    keystone = nixosTests.keystone;
    version = testers.testVersion {
      package = openstack-keystone;
      command = "keystone-manage --version";
    };
  };

  meta = {
    description = "OpenStack Identity (Keystone)";
    homepage = "https://github.com/openstack/keystone";
    license = lib.licenses.asl20;
    mainProgram = "keystone-manage";
    teams = [ lib.teams.openstack ];
  };
}
