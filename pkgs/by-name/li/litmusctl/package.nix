{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  kubectl,
  lib,
}:

buildGoModule rec {
  pname = "litmusctl";
  version = "1.15.0";

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    kubectl
  ];

  src = fetchFromGitHub {
    owner = "litmuschaos";
    repo = "litmusctl";
    rev = "${version}";
    hash = "sha256-SNqxfoYABKV4MheyP5G9nkRca/1+ozOPEvZAUtGdxh0=";
  };

  vendorHash = "sha256-7FYOQ89aUFPX+5NCPYKg+YGCXstQ6j9DK4V2mCgklu0=";

  postInstall = ''
    installShellCompletion --cmd litmusctl \
      --bash <($out/bin/litmusctl completion bash) \
      --fish <($out/bin/litmusctl completion fish) \
      --zsh <($out/bin/litmusctl completion zsh)
  '';

  meta = {
    description = "Command-Line tool to manage Litmuschaos's agent plane";
    homepage = "https://github.com/litmuschaos/litmusctl";
    license = lib.licenses.asl20;
    mainProgram = "litmusctl";
    maintainers = with lib.maintainers; [
      vinetos
      sailord
    ];
  };
}
