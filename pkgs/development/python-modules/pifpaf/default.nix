{
  lib,
  addBinToPathHook,
  buildPythonPackage,
  click,
  daiquiri,
  fetchPypi,
  fixtures,
  jinja2,
  pbr,
  psutil,
  pytestCheckHook,
  requests,
  setuptools-scm,
  setuptools,
  testtools,
  xattr,
}:

buildPythonPackage rec {
  pname = "pifpaf";
  version = "3.3.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xXkMj1sP1xXf6Ad/71BFbq8SHz/uHcaSqv6RQN0Ca1o=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    daiquiri
    fixtures
    jinja2
    pbr
    psutil
    xattr
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests
    testtools
    addBinToPathHook
  ];

  pythonImportsCheck = [ "pifpaf" ];

  meta = with lib; {
    description = "Suite of tools and fixtures to manage daemons for testing";
    mainProgram = "pifpaf";
    homepage = "https://github.com/jd/pifpaf";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
