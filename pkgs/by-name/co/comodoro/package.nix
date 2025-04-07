{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  installShellFiles,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  installManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  withTcp ? true,
}:

rustPlatform.buildRustPackage rec {
  pname = "comodoro";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "soywod";
    repo = "comodoro";
    tag = "v${version}";
    hash = "sha256-Y9SuxqI8wvoF0+X6CLNDlSFCwlSU8R73NYF/LjACP18=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-HzutYDphJdhNJ/jwyA5KVYr6fIutf73rYzKxrzVki9k=";

  nativeBuildInputs = lib.optional (installManPages || installShellCompletions) installShellFiles;

  buildNoDefaultFeatures = true;
  buildFeatures = lib.optional withTcp "tcp";

  postInstall =
    lib.optionalString installManPages ''
      mkdir -p $out/man
      $out/bin/comodoro man $out/man
      installManPage $out/man/*
    ''
    + lib.optionalString installShellCompletions ''
      installShellCompletion --cmd comodoro \
        --bash <($out/bin/comodoro completion bash) \
        --fish <($out/bin/comodoro completion fish) \
        --zsh <($out/bin/comodoro completion zsh)
    '';

  meta = with lib; {
    description = "CLI to manage your time";
    homepage = "https://github.com/pimalaya/comodoro";
    changelog = "https://github.com/soywod/comodoro/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ soywod ];
    mainProgram = "comodoro";
  };
}
