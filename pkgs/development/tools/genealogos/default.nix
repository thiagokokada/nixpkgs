{
  lib,
  rustPlatform,
  fetchFromGitHub,

  pkg-config,
  openssl,
}:
let
  mkGenealogosPackage =
    {
      crate ? "cli",
    }:
    rustPlatform.buildRustPackage rec {
      pname = "genealogos-${crate}";
      version = "1.0.0";

      src = fetchFromGitHub {
        owner = "tweag";
        repo = "genealogos";
        rev = "v${version}";
        hash = "sha256-EQrKInsrqlpjySX6duylo++2qwglB3EqGfLFJucOQM8=";
        # Genealogos' fixture tests contain valid nix store paths, and are thus incompatible with a fixed-output-derivation.
        # To avoid this, we just remove the tests
        postFetch = ''
          rm -r $out/genealogos/tests/
        '';
      };

      useFetchCargoVendor = true;
      cargoHash = "sha256-R3HQXPpTtqgXfc7nLNdJp5zUMEpfccKWOQtS5Y786Jc=";

      cargoBuildFlags = [
        "-p"
        "genealogos-${crate}"
      ];

      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ openssl ];

      # Since most tests were removed, just skip testing
      doCheck = false;

      meta = with lib; {
        description = "A Nix sbom generator";
        homepage = "https://github.com/tweag/genealogos";
        license = licenses.mit;
        maintainers = with maintainers; [ erin ];
        changelog = "https://github.com/tweag/genealogos/blob/${src.rev}/CHANGELOG.md";
        mainProgram = "genealogos";
        platforms = lib.platforms.unix;
      };
    };
in
{
  genealogos-cli = mkGenealogosPackage { };
  genealogos-api = mkGenealogosPackage { crate = "api"; };
}
