{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "should-dsl";
  version = "2.1.2";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "should_dsl";
    sha256 = "0ai30dxgygwzaj9sgdzyfr9p5b7gwc9piq59nzr4xy5x1zcm7xrn";
  };

  build-system = [ setuptools ];

  # There are no tests
  doCheck = false;

  meta = {
    description = "Should assertions in Python as clear and readable as possible";
    homepage = "https://github.com/nsi-iff/should-dsl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
