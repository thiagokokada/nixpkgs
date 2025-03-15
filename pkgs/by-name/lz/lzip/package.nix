{
  lib,
  stdenv,
  fetchurl,
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

stdenv.mkDerivation rec {
  pname = "lzip";
  version = "1.25";
  outputs = [
    "out"
    "man"
    "info"
  ];

  src = fetchurl {
    url = "mirror://savannah/lzip/${pname}-${version}.tar.gz";
    hash = "sha256-CUGKbY+4P1ET9b2FbglwPfXTe64DCMZo0PNG49PwpW8=";
  };

  patches = lib.optionals stdenv.hostPlatform.isMinGW [
    ./mingw-install-exe-file.patch
  ];

  configureFlags = [
    "CPPFLAGS=-DNDEBUG"
    "CFLAGS=-O3"
    "CXXFLAGS=-O3"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  setupHook = ./lzip-setup-hook.sh;

  doCheck = true;
  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://www.nongnu.org/lzip/lzip.html";
    description = "Lossless data compressor based on the LZMA algorithm";
    license = lib.licenses.gpl2Plus;
    maintainers = with maintainers; [ vlaci ];
    platforms = lib.platforms.all;
    mainProgram = "lzip";
  };
}
