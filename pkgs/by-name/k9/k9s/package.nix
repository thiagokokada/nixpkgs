{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
  nix-update-script,
  k9s,
  writableTmpDirAsHomeHook,
}:

buildGoModule rec {
  pname = "k9s";
  version = "0.40.10";

  src = fetchFromGitHub {
    owner = "derailed";
    repo = "k9s";
    rev = "v${version}";
    hash = "sha256-QGymGiTHT3Qnf9l/hhE3lgJ7TBBjKMe2k1aJ32khU0E=";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/derailed/k9s/cmd.version=${version}"
    "-X github.com/derailed/k9s/cmd.commit=${src.rev}"
    "-X github.com/derailed/k9s/cmd.date=1970-01-01T00:00:00Z"
  ];

  tags = [ "netcgo" ];

  proxyVendor = true;

  vendorHash = "sha256-jAxrOdQcMIH7uECKGuuiTZlyV4aJ/a76IuKGouWg/r4=";

  # TODO investigate why some config tests are failing
  doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64);

  # For arch != x86
  # {"level":"fatal","error":"could not create any of the following paths: /homeless-shelter/.config, /etc/xdg","time":"2022-06-28T15:52:36Z","message":"Unable to create configuration directory for k9s"}
  passthru = {
    tests.version = testers.testVersion {
      package = k9s;
      command = "HOME=$(mktemp -d) k9s version -s";
      inherit version;
    };
    updateScript = nix-update-script { };
  };

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    # k9s requires a writeable log directory
    # Otherwise an error message is printed
    # into the completion scripts
    export K9S_LOGS_DIR=$(mktemp -d)

    installShellCompletion --cmd k9s \
      --bash <($out/bin/k9s completion bash) \
      --fish <($out/bin/k9s completion fish) \
      --zsh <($out/bin/k9s completion zsh)
  '';

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  meta = with lib; {
    description = "Kubernetes CLI To Manage Your Clusters In Style";
    homepage = "https://github.com/derailed/k9s";
    changelog = "https://github.com/derailed/k9s/releases/tag/v${version}";
    license = licenses.asl20;
    mainProgram = "k9s";
    maintainers = with maintainers; [
      Gonzih
      markus1189
      bryanasdev000
      qjoly
    ];
  };
}
