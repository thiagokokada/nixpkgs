#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused nix jq

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

latestVersion="$(curl --fail -s ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} "https://api.github.com/repos/brave/brave-browser/releases/latest" | jq -r '.tag_name' | sed 's/^v//')"

hashAarch64="$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://github.com/brave/brave-browser/releases/download/v${latestVersion}/brave-browser_${latestVersion}_arm64.deb")")"
hashAmd64="$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://github.com/brave/brave-browser/releases/download/v${latestVersion}/brave-browser_${latestVersion}_amd64.deb")")"
hashAarch64Darwin="$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://github.com/brave/brave-browser/releases/download/v${latestVersion}/brave-v${latestVersion}-darwin-arm64.zip")")"
hashAmd64Darwin="$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 "https://github.com/brave/brave-browser/releases/download/v${latestVersion}/brave-v${latestVersion}-darwin-x64.zip")")"

cat > $SCRIPT_DIR/package.nix << EOF
# Expression generated by update.sh; do not edit it by hand!
{ stdenv, callPackage, ... }@args:

let
  pname = "brave";
  version = "${latestVersion}";

  allArchives = {
    aarch64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v\${version}/brave-browser_\${version}_arm64.deb";
      hash = "${hashAarch64}";
    };
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v\${version}/brave-browser_\${version}_amd64.deb";
      hash = "${hashAmd64}";
    };
    aarch64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v\${version}/brave-v\${version}-darwin-arm64.zip";
      hash = "${hashAarch64Darwin}";
    };
    x86_64-darwin = {
      url = "https://github.com/brave/brave-browser/releases/download/v\${version}/brave-v\${version}-darwin-x64.zip";
      hash = "${hashAmd64Darwin}";
    };
  };

  archive =
    if builtins.hasAttr stdenv.system allArchives then
      allArchives.\${stdenv.system}
    else
      throw "Unsupported platform.";

in
callPackage ./make-brave.nix (removeAttrs args [ "callPackage" ]) (
  archive
  // {
    inherit pname version;
    platform = stdenv.system;
  }
)
EOF
