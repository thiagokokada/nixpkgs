{
  stdenv,
  lib,
  runCommand,
  patchelf,
  makeWrapper,
  pkg-config,
  curl,
  runtimeShell,
  openssl,
  zlib,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
}:

rustPlatform.buildRustPackage rec {
  pname = "elan";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "elan";
    rev = "v${version}";
    hash = "sha256-3L5kGcj+iXjVYV4ZlBfHsVfOWQVv6iJ325Phtqi3GQA=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-FO/Qd6hIl34YCW9nWKtv0fykbqyL+vbmWboewTB9Dak=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  OPENSSL_NO_VENDOR = 1;
  buildInputs = [
    curl
    zlib
    openssl
  ] ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  buildFeatures = [ "no-self-update" ];

  patches = lib.optionals stdenv.hostPlatform.isLinux [
    # Run patchelf on the downloaded binaries.
    # This is necessary because Lean 4 is now dynamically linked.
    (runCommand "0001-dynamically-patchelf-binaries.patch"
      {
        CC = stdenv.cc;
        cc = "${stdenv.cc}/bin/cc";
        ar = "${stdenv.cc}/bin/ar";
        patchelf = patchelf;
        shell = runtimeShell;
      }
      ''
        export dynamicLinker=$(cat $CC/nix-support/dynamic-linker)
        substitute ${./0001-dynamically-patchelf-binaries.patch} $out \
          --subst-var patchelf \
          --subst-var dynamicLinker \
          --subst-var cc \
          --subst-var ar \
          --subst-var shell
      ''
    )
  ];

  postInstall = ''
    pushd $out/bin
    mv elan-init elan
    for link in lean leanpkg leanchecker leanc leanmake lake; do
      ln -s elan $link
    done
    popd

    # tries to create .elan
    export HOME=$(mktemp -d)
    mkdir -p "$out/share/"{bash-completion/completions,fish/vendor_completions.d,zsh/site-functions}
    $out/bin/elan completions bash > "$out/share/bash-completion/completions/elan"
    $out/bin/elan completions fish > "$out/share/fish/vendor_completions.d/elan.fish"
    $out/bin/elan completions zsh >  "$out/share/zsh/site-functions/_elan"
  '';

  meta = with lib; {
    description = "Small tool to manage your installations of the Lean theorem prover";
    homepage = "https://github.com/leanprover/elan";
    changelog = "https://github.com/leanprover/elan/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      asl20 # or
      mit
    ];
    maintainers = with maintainers; [ ];
    mainProgram = "elan";
  };
}
