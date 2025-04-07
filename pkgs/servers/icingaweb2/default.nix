{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  makeWrapper,
  php83,
  nixosTests,
}:

stdenvNoCC.mkDerivation rec {
  pname = "icingaweb2";
  version = "2.12.3";

  src = fetchFromGitHub {
    owner = "Icinga";
    repo = "icingaweb2";
    tag = "v${version}";
    hash = "sha256-PWP5fECKjdXhdX1E5hYaGv/fqb1KIKfclcPiCY/MMZM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share
    cp -ra application bin etc library modules public $out
    cp -ra doc $out/share

    wrapProgram $out/bin/icingacli --prefix PATH : "${lib.makeBinPath [ php83 ]}"
  '';

  passthru.tests = { inherit (nixosTests) icingaweb2; };

  meta = with lib; {
    description = "Webinterface for Icinga 2";
    longDescription = ''
      A lightweight and extensible web interface to keep an eye on your environment.
      Analyse problems and act on them.
    '';
    homepage = "https://www.icinga.com/products/icinga-web-2/";
    license = licenses.gpl2Plus;
    maintainers = teams.helsinki-systems.members;
    mainProgram = "icingacli";
    platforms = platforms.all;
  };
}
