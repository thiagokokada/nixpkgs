{
  lib,
  buildLua,
  fetchFromGitHub,
  makeFontsConf,
  nix-update-script,
}:
buildLua (finalAttrs: {
  pname = "modernx-zydezu";
  version = "0.3.8";

  scriptPath = "modernx.lua";
  src = fetchFromGitHub {
    owner = "zydezu";
    repo = "ModernX";
    rev = finalAttrs.version;
    hash = "sha256-dHjEmE/m5lAF3XyyebO/23BLmoS5sfSoNZuTtJv/JEA=";
  };

  postInstall = ''
    mkdir -p $out/share/fonts
    cp -r *.ttf $out/share/fonts
  '';
  passthru.extraWrapperArgs = [
    "--set"
    "FONTCONFIG_FILE"
    (toString (makeFontsConf {
      fontDirectories = [ "${finalAttrs.finalPackage}/share/fonts" ];
    }))
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern OSC UI replacement for MPV that retains the functionality of the default OSC";
    changelog = "https://github.com/zydezu/ModernX/releases/tag/${finalAttrs.version}";
    homepage = "https://github.com/zydezu/ModernX";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      Guanran928
    ];
  };
})
