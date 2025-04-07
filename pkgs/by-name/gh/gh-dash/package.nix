{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  gh-dash,
}:

buildGoModule rec {
  pname = "gh-dash";
  version = "4.12.0";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = "gh-dash";
    tag = "v${version}";
    hash = "sha256-qtSJbp9BGX4669fl/B1Z6rGG3432Nj1IQ+aYfIE9W50=";
  };

  vendorHash = "sha256-7s+Lp8CHo1+h2TmbTOcAGZORK+/1wytk4nv9fgD2Mhw=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dlvhdr/gh-dash/v4/cmd.Version=${version}"
  ];

  passthru.tests = {
    version = testers.testVersion { package = gh-dash; };
  };

  meta = {
    changelog = "https://github.com/dlvhdr/gh-dash/releases/tag/${src.rev}";
    description = "Github Cli extension to display a dashboard with pull requests and issues";
    homepage = "https://github.com/dlvhdr/gh-dash";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ amesgen ];
    mainProgram = "gh-dash";
  };
}
