{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pytest-cov-stub,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pynmeagps";
  version = "1.0.45";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pynmeagps";
    tag = "v${version}";
    hash = "sha256-LAWve4Qrc7Kf4b/2+oNTZUnDQWMleuxeeBN/A3jR+rs=";
  };

  build-system = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pythonImportsCheck = [ "pynmeagps" ];

  meta = {
    description = "NMEA protocol parser and generator";
    homepage = "https://github.com/semuconsulting/pynmeagps";
    changelog = "https://github.com/semuconsulting/pynmeagps/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dylan-gonzalez ];
  };
}
