{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  nix-update-script,
  prefetch-yarn-deps,
  fixup-yarn-lock,
  nodejs,
  yarn,
  nixosTests,
}:

stdenv.mkDerivation rec {
  pname = "outline";
  version = "0.82.0";

  src = fetchFromGitHub {
    owner = "outline";
    repo = "outline";
    tag = "v${version}";
    hash = "sha256-nCXyR4k/Ny0OLAE18B+GJDyOMTjt6rc375yj+d+c8zQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    prefetch-yarn-deps
    fixup-yarn-lock
  ];
  buildInputs = [
    yarn
    nodejs
  ];

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-RDMVlSVYPGAuyOTcI2CBgaaZ5wNT7lznYb4jbirKmqk=";
  };

  configurePhase = ''
    export HOME=$(mktemp -d)/yarn_home
  '';

  buildPhase = ''
    runHook preBuild
    export NODE_OPTIONS=--openssl-legacy-provider

    yarn config --offline set yarn-offline-mirror $yarnOfflineCache
    fixup-yarn-lock yarn.lock

    yarn install --offline \
      --frozen-lockfile \
      --ignore-engines --ignore-scripts
    patchShebangs node_modules/
    # apply upstream patches with `patch-package`
    yarn run postinstall
    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/outline
    mv build server public node_modules $out/share/outline/

    node_modules=$out/share/outline/node_modules
    build=$out/share/outline/build
    server=$out/share/outline/server

    makeWrapper ${nodejs}/bin/node $out/bin/outline-server \
      --add-flags $build/server/index.js \
      --set NODE_ENV production \
      --set NODE_PATH $node_modules \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} # required to run migrations

    runHook postInstall
  '';

  passthru = {
    tests = {
      basic-functionality = nixosTests.outline;
    };
    updateScript = nix-update-script { };
    # alias for nix-update to be able to find and update this attribute
    offlineCache = yarnOfflineCache;
  };

  meta = with lib; {
    description = "Fastest wiki and knowledge base for growing teams. Beautiful, feature rich, and markdown compatible";
    homepage = "https://www.getoutline.com/";
    changelog = "https://github.com/outline/outline/releases";
    license = licenses.bsl11;
    maintainers =
      with maintainers;
      [
        cab404
        yrd
      ]
      ++ teams.cyberus.members;
    platforms = platforms.linux;
  };
}
