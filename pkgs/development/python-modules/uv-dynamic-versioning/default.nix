{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  hatchling,

  # dependencies
  dunamai,
  eval-type-backport,
  jinja2,
  pydantic,
  returns,
  tomlkit,

  # tests
  gitpython,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "uv-dynamic-versioning";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ninoseki";
    repo = "uv-dynamic-versioning";
    tag = "v${version}";
    # Tests perform mock operations on the local repo
    leaveDotGit = true;
    hash = "sha256-DO10OGij7koV5VYqywRR28pg0sEOAuGpqz1Ksf39MQo=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    dunamai
    eval-type-backport
    hatchling
    jinja2
    pydantic
    returns
    tomlkit
  ];

  pythonImportsCheck = [
    "uv_dynamic_versioning"
  ];

  preCheck = ''
    git config --global user.email "nobody@example.com"
    git config --global user.name "Nobody"
  '';

  nativeCheckInputs = [
    gitpython
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  meta = {
    description = "Dynamic versioning based on VCS tags for uv/hatch project";
    homepage = "https://github.com/ninoseki/uv-dynamic-versioning";
    changelog = "https://github.com/ninoseki/uv-dynamic-versioning/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
