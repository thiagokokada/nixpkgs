{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  openssh,
}:

buildGoModule rec {
  pname = "bosh-cli";

  version = "7.9.5";

  src = fetchFromGitHub {
    owner = "cloudfoundry";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-CyrOsPx55hZubBV0t5uMTTLVWC1qmEym1IwinvmSlWM=";
  };
  vendorHash = null;

  postPatch = ''
    substituteInPlace cmd/version.go --replace '[DEV BUILD]' '${version}'
  '';

  nativeBuildInputs = [ makeWrapper ];

  subPackages = [ "." ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/bosh-cli $out/bin/bosh
    wrapProgram $out/bin/bosh --prefix PATH : '${lib.makeBinPath [ openssh ]}'
  '';

  meta = with lib; {
    description = "Command line interface to CloudFoundry BOSH";
    homepage = "https://bosh.io";
    changelog = "https://github.com/cloudfoundry/bosh-cli/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ ris ];
    mainProgram = "bosh";
  };
}
