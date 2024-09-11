{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ilmbase,
  openexr_3,
  libtiff,
  aces-container,
}:

stdenv.mkDerivation rec {
  pname = "ctl";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "ampas";
    repo = "CTL";
    rev = "ctl-${version}";
    hash = "sha256-jG+38jsPw+4CEAbOG+hudfPBPbZLG+Om7PszkFa6DuI=";
  };

  nativeBuildInputs = [
    cmake
    ilmbase
    openexr_3
    libtiff
    aces-container
  ];

  meta = {
    description = "Programming language for digital color management";
    homepage = "https://github.com/ampas/CTL";
    changelog = "https://github.com/ampas/CTL/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.ampas;
    maintainers = with lib.maintainers; [ paperdigits ];
    mainProgram = "ctl";
    platforms = lib.platforms.all;
  };
}
