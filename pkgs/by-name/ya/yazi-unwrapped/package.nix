{
  rustPlatform,
  fetchFromGitHub,
  lib,

  installShellFiles,
  stdenv,
  Foundation,
  rust-jemalloc-sys,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yazi";
  version = "25.4.8";

  srcs = builtins.attrValues finalAttrs.passthru.srcs;

  sourceRoot = finalAttrs.passthru.srcs.code_src.name;

  useFetchCargoVendor = true;
  cargoHash = "sha256-RqAolwIQqJQo9cVZ1uA0D+6yAmQKN2a7Uk3f4b/FjHU=";

  env.YAZI_GEN_COMPLETIONS = true;
  env.VERGEN_GIT_SHA = "Nixpkgs";
  env.VERGEN_BUILD_DATE = "2025-04-08";

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ rust-jemalloc-sys ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ Foundation ];

  postInstall = ''
    installShellCompletion --cmd yazi \
      --bash ./yazi-boot/completions/yazi.bash \
      --fish ./yazi-boot/completions/yazi.fish \
      --zsh  ./yazi-boot/completions/_yazi

    installManPage ../${finalAttrs.passthru.srcs.man_src.name}/yazi{.1,-config.5}

    install -Dm444 assets/yazi.desktop -t $out/share/applications
    install -Dm444 assets/logo.png $out/share/pixmaps/yazi.png
  '';

  passthru.updateScript.command = [ ./update.sh ];
  passthru.srcs = {
    code_src = fetchFromGitHub {
      owner = "sxyazi";
      repo = "yazi";
      tag = "v${finalAttrs.version}";
      hash = "sha256-oxO7nT4AZJilxA2DliYk57NETHu78xQ8nFdV+UwyKHE=";
    };

    man_src = fetchFromGitHub {
      name = "manpages"; # needed to ensure name is unique
      owner = "yazi-rs";
      repo = "manpages";
      rev = "8950e968f4a1ad0b83d5836ec54a070855068dbf";
      hash = "sha256-kEVXejDg4ChFoMNBvKlwdFEyUuTcY2VuK9j0PdafKus=";
    };
  };

  meta = {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      eljamm
      khaneliman
      linsui
      matthiasbeyer
      uncenter
      xyenon
    ];
    mainProgram = "yazi";
  };
})
