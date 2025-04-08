{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  Security,
}:

rustPlatform.buildRustPackage rec {
  pname = "hyperfine";
  version = "1.19.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "hyperfine";
    tag = "v${version}";
    hash = "sha256-c8yK9U8UWRWUSGGGrAds6zAqxAiBLWq/RcZ6pvYNpgk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-eZpGqkowp/R//RqLRk3AIbTpW3i9e+lOWpfdli7S4uE=";

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin Security;

  postInstall = ''
    installManPage doc/hyperfine.1

    installShellCompletion \
      $releaseDir/build/hyperfine-*/out/hyperfine.{bash,fish} \
      --zsh $releaseDir/build/hyperfine-*/out/_hyperfine
  '';

  meta = with lib; {
    description = "Command-line benchmarking tool";
    homepage = "https://github.com/sharkdp/hyperfine";
    changelog = "https://github.com/sharkdp/hyperfine/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      asl20 # or
      mit
    ];
    maintainers = with maintainers; [
      figsoda
      thoughtpolice
    ];
    mainProgram = "hyperfine";
  };
}
