{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  pkg-config,
  libpulseaudio,
  dbus,
  openssl,
  speechd-minimal,
}:

rustPlatform.buildRustPackage rec {
  pname = "goxlr-utility";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "GoXLR-on-Linux";
    repo = "goxlr-utility";
    tag = "v${version}";
    hash = "sha256-aThIu+3eNHCKS6lsio7cLZeIMg0509qkE0YQ6M6vPAI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-EhqniqdgD95yUwiaqlA0vtRZfq4cR7wxsGPmjpvzgdI=";

  buildInputs = [
    libpulseaudio
    dbus
    speechd-minimal
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    rustPlatform.bindgenHook
  ];

  buildFeatures = [ "tts" ];

  postInstall = ''
    install -Dm644 "50-goxlr.rules" "$out/etc/udev/rules.d/50-goxlr.rules"
    install -Dm644 "daemon/resources/goxlr-utility.png" "$out/share/icons/hicolor/48x48/apps/goxlr-utility.png"
    install -Dm644 "daemon/resources/goxlr-utility.svg" "$out/share/icons/hicolor/scalable/apps/goxlr-utility.svg"
    install -Dm644 "daemon/resources/goxlr-utility-large.png" "$out/share/pixmaps/goxlr-utility.png"
    install -Dm644 "daemon/resources/goxlr-utility.desktop" "$out/share/applications/goxlr-utility.desktop"
    substituteInPlace $out/share/applications/goxlr-utility.desktop \
      --replace-fail /usr/bin $out/bin

    completions_dir=$(dirname $(find target -name 'goxlr-client.bash' | head -n 1))
    installShellCompletion --bash $completions_dir/goxlr-client.bash
    installShellCompletion --fish $completions_dir/goxlr-client.fish
    installShellCompletion --zsh  $completions_dir/_goxlr-client
    completions_dir=$(dirname $(find target -name 'goxlr-daemon.bash' | head -n 1))
    installShellCompletion --bash $completions_dir/goxlr-daemon.bash
    installShellCompletion --fish $completions_dir/goxlr-daemon.fish
    installShellCompletion --zsh  $completions_dir/_goxlr-daemon
  '';

  meta = with lib; {
    description = "Unofficial GoXLR App replacement for Linux, Windows and MacOS";
    homepage = "https://github.com/GoXLR-on-Linux/goxlr-utility";
    license = licenses.mit;
    maintainers = with maintainers; [ errnoh ];
  };
}
