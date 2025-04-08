{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  lcms2,
  pkg-config,

  # for passthru.tests
  freeimage,
  hdrmerge,
  imagemagick,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "libraw";
  version = "0.21.3";

  src = fetchFromGitHub {
    owner = "LibRaw";
    repo = "LibRaw";
    tag = version;
    hash = "sha256-QFyRQ0V7din/rnkRvEWf521kSzN7HwJ3kZiQ43PAmVI=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "doc"
  ];

  propagatedBuildInputs = [ lcms2 ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  enableParallelBuilding = true;

  postPatch = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    substituteInPlace libraw*.pc.in --replace-fail -lstdc++ ""
  '';

  passthru.tests = {
    inherit imagemagick hdrmerge freeimage;
    inherit (python3.pkgs) rawkit;
  };

  meta = with lib; {
    description = "Library for reading RAW files obtained from digital photo cameras (CRW/CR2, NEF, RAF, DNG, and others)";
    homepage = "https://www.libraw.org/";
    license = with licenses; [
      cddl
      lgpl2Plus
    ];
    platforms = platforms.unix;
  };
}
