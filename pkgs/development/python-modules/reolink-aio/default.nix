{
  lib,
  aiohttp,
  aiortsp,
  buildPythonPackage,
  fetchFromGitHub,
  orjson,
  pycryptodomex,
  pythonOlder,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "reolink-aio";
  version = "0.13.2";
  pyproject = true;

  disabled = pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "starkillerOG";
    repo = "reolink_aio";
    tag = version;
    hash = "sha256-khO8mu2aWBU9TiorKkMd1e54r5C7ovv6eWyJ61dzOJw=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiortsp
    orjson
    pycryptodomex
    typing-extensions
  ];

  pythonImportsCheck = [ "reolink_aio" ];

  # All tests require a network device
  doCheck = false;

  meta = with lib; {
    description = "Module to interact with the Reolink IP camera API";
    homepage = "https://github.com/starkillerOG/reolink_aio";
    changelog = "https://github.com/starkillerOG/reolink_aio/releases/tag/${src.tag}";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
