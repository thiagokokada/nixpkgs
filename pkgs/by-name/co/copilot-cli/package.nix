{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
  copilot-cli,
}:

buildGoModule rec {
  pname = "copilot-cli";
  version = "1.34.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-iipDvjPCNtk6wHjukgtnWzz0qwAJOU9DpolesNM2ELo=";
  };

  vendorHash = "sha256-VzvbWh3qk9YvUdzlFa0UZMlNpjtLn1WJY4oN6/QPuuo=";

  nativeBuildInputs = [ installShellFiles ];

  # follow LINKER_FLAGS in Makefile
  ldflags = [
    "-s"
    "-w"
    "-X github.com/aws/copilot-cli/internal/pkg/version.Version=v${version}"
    "-X github.com/aws/copilot-cli/internal/pkg/cli.binaryS3BucketPath=https://ecs-cli-v2-release.s3.amazonaws.com"
  ];

  subPackages = [ "./cmd/copilot" ];

  postInstall = ''
    installShellCompletion --cmd copilot \
      --bash <($out/bin/copilot completion bash) \
      --fish <($out/bin/copilot completion fish) \
      --zsh <($out/bin/copilot completion zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = copilot-cli;
    command = "copilot version";
    version = "v${version}";
  };

  meta = with lib; {
    description = "Build, Release and Operate Containerized Applications on AWS";
    homepage = "https://github.com/aws/copilot-cli";
    changelog = "https://github.com/aws/copilot-cli/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ jiegec ];
    mainProgram = "copilot";
  };
}
