{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  mock,
  oslo-config,
  pytest-cov,
  pytest-xdist,
  pytest,
  pytestCheckHook,
  setproctitle,
  setuptools-scm,
  setuptools,
  sphinx,
  sphinx-rtd-theme,
}:

buildPythonPackage rec {
  pname = "cotyledon";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sileht";
    repo = "cotyledon";
    tag = version;
    hash = "sha256-70gEIuaGfYH/EJ0UvfIq6d674kyCP7jfccoiwZXnSEM=";
  };

  postPatch = ''
    substituteInPlace tox.ini \
      --replace-fail '--numprocesses=auto' "--numprocesses=1"
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    setproctitle
  ];

  optional-dependencies = {
    doc = [
      sphinx
      sphinx-rtd-theme
    ];
    oslo = [ oslo-config ];
    test = [
      mock
      pytest
      pytest-cov
      pytest-xdist
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ optional-dependencies.oslo
  ++ optional-dependencies.test;

  disabledTests = [
    # Disable slow tests
    "test_workflow"
    "test_options"
    "test_sighup"
  ];

  preCheck = ''
    rm -rf cotyledon/tests
  '';

  pythonImportsCheck = [ "cotyledon" ];

  meta = {
    description = "Framework for defining long-running services";
    homepage = "https://github.com/sileht/cotyledon";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.anthonyroussel ];
  };
}
