{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  buildPackages,
  versionCheckHook,
  nix-update-script,
  vscode-extensions,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinymist";
  # Please update the corresponding vscode extension when updating
  # this derivation.
  version = "0.13.8";

  src = fetchFromGitHub {
    owner = "Myriad-Dreamin";
    repo = "tinymist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dKLHZyFkTo6iCw/s73asJqXoNBpYx7UC/r2qVp5dLjs=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-XbPqddmVv5zubnbT5IewAcvPJWQMIumWgGI+q/r1Ip4=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  checkFlags = [
    "--skip=e2e"

    # Require internet access
    "--skip=docs::package::tests::cetz"
    "--skip=docs::package::tests::tidy"
    "--skip=docs::package::tests::touying"

    # Tests are flaky for unclear reasons since the 0.12.3 release
    # Reported upstream: https://github.com/Myriad-Dreamin/tinymist/issues/868
    "--skip=analysis::expr_tests::scope"
    "--skip=analysis::post_type_check_tests::test"
    "--skip=analysis::type_check_tests::test"
    "--skip=completion::tests::test_pkgs"
    "--skip=folding_range::tests::test"
    "--skip=goto_definition::tests::test"
    "--skip=hover::tests::test"
    "--skip=inlay_hint::tests::smart"
    "--skip=prepare_rename::tests::prepare"
    "--skip=references::tests::test"
    "--skip=rename::tests::test"
    "--skip=semantic_tokens_full::tests::test"
  ];

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd tinymist \
        --bash <(${emulator} $out/bin/tinymist completion bash) \
        --fish <(${emulator} $out/bin/tinymist completion fish) \
        --zsh <(${emulator} $out/bin/tinymist completion zsh)
    '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "-V";
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      vscode-extension = vscode-extensions.myriad-dreamin.tinymist;
    };
  };

  meta = {
    description = "Tinymist is an integrated language service for Typst";
    homepage = "https://github.com/Myriad-Dreamin/tinymist";
    changelog = "https://github.com/Myriad-Dreamin/tinymist/blob/v${finalAttrs.version}/editors/vscode/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "tinymist";
    maintainers = with lib.maintainers; [
      GaetanLepage
      lampros
    ];
  };
})
