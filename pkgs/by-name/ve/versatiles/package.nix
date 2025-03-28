{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "versatiles";
  version = "0.15.3"; # When updating: Replace with current version

  src = fetchFromGitHub {
    owner = "versatiles-org";
    repo = "versatiles-rs";
    tag = "v${version}"; # When updating: Replace with long commit hash of new version
    hash = "sha256-xIZ/9l/wvl2Gh7vmxTGUxhZ9KIPSPLoqqC8DRN3PiQs="; # When updating: Use `lib.fakeHash` for recomputing the hash once. Run: 'nix-build -A versatiles'. Swap with new hash and proceed.
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-UkPKwXPQW/M7AgNTMx4OqTLQCc9+c+RkzcCPyEHJayw="; # When updating: Same as above

  __darwinAllowLocalNetworking = true;

  # Testing only necessary for the `bins` and `lib` features
  cargoTestFlags = [
    "--bins"
    "--lib"
  ];

  # Skip tests that require network access
  checkFlags = [
    "--skip=tools::convert::tests::test_remote1"
    "--skip=tools::convert::tests::test_remote2"
    "--skip=tools::probe::tests::test_remote"
    "--skip=tools::serve::tests::test_remote"
    "--skip=utils::io::data_reader_http"
    "--skip=utils::io::data_reader_http::tests::read_range_git"
    "--skip=utils::io::data_reader_http::tests::read_range_googleapis"
    "--skip=io::data_reader_http::tests::read_range_git"
    "--skip=io::data_reader_http::tests::read_range_googleapis"
  ];

  meta = {
    description = "Toolbox for converting, checking and serving map tiles in various formats";
    longDescription = ''
      VersaTiles is a Rust-based project designed for processing and serving tile data efficiently.
      It supports multiple tile formats and offers various functionalities for handling tile data.
    '';
    homepage = "https://versatiles.org/";
    downloadPage = "https://github.com/versatiles-org/versatiles-rs";
    changelog = "https://github.com/versatiles-org/versatiles-rs/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wilhelmines ];
    mainProgram = "versatiles";
    platforms = with lib.platforms; linux ++ darwin ++ windows;
  };
}
