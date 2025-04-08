{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  ncurses,
  openssl,
  pkg-config,
  Security,
}:

rustPlatform.buildRustPackage rec {
  pname = "wiki-tui";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Builditluc";
    repo = "wiki-tui";
    tag = "v${version}";
    hash = "sha256-eTDxRrTP9vX7F1lmDCuF6g1pfaZChqB8Pv1kfrd7I9w=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ncurses
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ Security ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-Pe6mNbn4GFjhpFZeWMlaRt7Bj5BLiIy789hXWkII2ps=";

  meta = with lib; {
    description = "Simple and easy to use Wikipedia Text User Interface";
    homepage = "https://github.com/builditluc/wiki-tui";
    changelog = "https://github.com/Builditluc/wiki-tui/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [
      lom
      builditluc
      matthiasbeyer
    ];
    mainProgram = "wiki-tui";
  };
}
