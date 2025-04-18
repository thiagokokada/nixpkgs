{
  mkKdeDerivation,
  sources,
  corrosion,
  xapian,
  rustPlatform,
  cargo,
  rustc,
}:
mkKdeDerivation rec {
  pname = "akonadi-search";
  inherit (sources.${pname}) version;

  cargoRoot = "agent/rs/htmlparser";

  cargoDeps = rustPlatform.fetchCargoVendor {
    # include version in the name so we invalidate the FOD
    name = "${pname}-${version}";
    src = sources.${pname};
    sourceRoot = "${pname}-${version}/${cargoRoot}";
    hash = "sha256-hdm4LfQcs4TTfBLzlZYJ0uzqfLxMXuYQExLGJg81W2U=";
  };

  extraNativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  extraBuildInputs = [
    corrosion
    xapian
  ];
}
