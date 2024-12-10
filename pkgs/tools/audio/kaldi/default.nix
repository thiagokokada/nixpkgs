{ lib
, stdenv
, openblas
, blas
, lapack
, icu
, cmake
, pkg-config
, fetchFromGitHub
, python3
, Accelerate
, _experimental-update-script-combinators
, common-updater-scripts
, ripgrep
, unstableGitUpdater
, writeShellScript
}:

assert blas.implementation == "openblas" && lapack.implementation == "openblas";
stdenv.mkDerivation (finalAttrs: {
  pname = "kaldi";
  version = "0-unstable-2024-11-29";

  src = fetchFromGitHub {
    owner = "kaldi-asr";
    repo = "kaldi";
    rev = "701f13107fda71195ab76a7f9f51ed45ce4ec728";
    sha256 = "sha256-Uusj5nkLyOiPI0mAdlykBDNEzHWE+tU/kUhVYzwjhOY=";
  };

  cmakeFlags = [
    "-DKALDI_BUILD_TEST=off"
    "-DBUILD_SHARED_LIBS=on"
    "-DBLAS_LIBRARIES=-lblas"
    "-DLAPACK_LIBRARIES=-llapack"
    "-DFETCHCONTENT_SOURCE_DIR_OPENFST:PATH=${finalAttrs.passthru.sources.openfst}"
  ];

  buildInputs = [
    openblas
    icu
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    Accelerate
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  preConfigure = ''
    cmakeFlagsArray+=(
      # Extract version without the need for git.
      # https://github.com/kaldi-asr/kaldi/blob/71f38e62cad01c3078555bfe78d0f3a527422d75/cmake/VersionHelper.cmake
      # Patch number is not actually used by default so we can just ignore it.
      # https://github.com/kaldi-asr/kaldi/blob/71f38e62cad01c3078555bfe78d0f3a527422d75/CMakeLists.txt#L214
      "-DKALDI_VERSION=$(cat src/.version)"
    )
  '';

  postInstall = ''
    mkdir -p $out/share/kaldi
    cp -r ../egs $out/share/kaldi
  '';

  passthru = {
    sources = {
      # rev from https://github.com/kaldi-asr/kaldi/blob/master/cmake/third_party/openfst.cmake
      openfst = fetchFromGitHub {
        owner = "kkm000";
        repo = "openfst";
        rev = "338225416178ac36b8002d70387f5556e44c8d05";
        hash = "sha256-MGEUuw7ex+WcujVdxpO2Bf5sB6Z0edcAeLGqW/Lo1Hs=";
      };
    };

    updateScript =
      let
        updateSource = unstableGitUpdater {};
        updateOpenfst = writeShellScript "update-openfst" ''
          hash=$(${ripgrep}/bin/rg --multiline --pcre2 --only-matching 'FetchContent_Declare\(\s*openfst[^)]*GIT_TAG\s*([0-9a-f]{40})' --replace '$1' "${finalAttrs.src}/cmake/third_party/openfst.cmake")
          ${common-updater-scripts}/bin/update-source-version kaldi.sources.openfst "$hash" --source-key=out "--version-key=rev"
        '';
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updateOpenfst
      ];
  };

  meta = with lib; {
    description = "Speech Recognition Toolkit";
    homepage = "https://kaldi-asr.org";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
})
