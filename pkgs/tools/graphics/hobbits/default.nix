{
  lib,
  stdenv,
  mkDerivation,
  fetchFromGitHub,
  cmake,
  pkg-config,
  pffft,
  libpcap,
  libusb1,
  python3,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "hobbits";
  version = "0.55.0";

  src = fetchFromGitHub {
    owner = "Mahlet-Inc";
    repo = "hobbits";
    rev = "v${version}";
    hash = "sha256-W6QBLj+GkmM88cOVSIc1PLiVXysjv74J7citFW6SRDM=";
  };

  postPatch = ''
    substituteInPlace src/hobbits-core/settingsdata.cpp \
      --replace "pythonHome = \"/usr\"" "pythonHome = \"${python3}\""
    substituteInPlace cmake/gitversion.cmake \
      --replace "[Mystery Build]" "${version}"
  '';

  buildInputs = [
    pffft
    libpcap
    libusb1
    python3
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  cmakeFlags = [ "-DUSE_SYSTEM_PFFFT=ON" ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isAarch64 "-Wno-error=narrowing";

  meta = with lib; {
    description = "Multi-platform GUI for bit-based analysis, processing, and visualization";
    homepage = "https://github.com/Mahlet-Inc/hobbits";
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
