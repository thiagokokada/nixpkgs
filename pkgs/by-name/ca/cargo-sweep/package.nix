{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-sweep";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "holmgr";
    repo = "cargo-sweep";
    tag = "v${version}";
    sha256 = "sha256-L9tWTgW8PIjxeby+wa71NPp3kWMYH5D7PNtpk8Bmeyc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-FCpCGp2WUTKTjvUewcOqLoNPlZDnOa4TsamSQNU1xxU=";

  checkFlags = [
    # Requires a rustup toolchain to be installed.
    "--skip check_toolchain_listing_on_multiple_projects"
    # Does not work with a `--target` build in the environment
    "--skip empty_project_output"
  ];

  meta = with lib; {
    description = "Cargo subcommand for cleaning up unused build files generated by Cargo";
    mainProgram = "cargo-sweep";
    homepage = "https://github.com/holmgr/cargo-sweep";
    license = licenses.mit;
    maintainers = with maintainers; [
      xrelkd
      matthiasbeyer
    ];
  };
}
