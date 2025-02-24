{
  lib,
  config,
  pkgs ? import <nixpkgs> { },
  licenseAccepted ? config.android_sdk.accept_license or (builtins.getEnv "NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE" == "1"),
}:

lib.recurseIntoAttrs rec {
  composeAndroidPackages = pkgs.callPackage ./compose-android-packages.nix {
    inherit licenseAccepted meta;
  };

  buildApp = pkgs.callPackage ./build-app.nix {
    inherit composeAndroidPackages meta;
  };

  emulateApp = pkgs.callPackage ./emulate-app.nix {
    inherit composeAndroidPackages meta;
  };

  androidPkgs = composeAndroidPackages {
    platformVersions = [
      "28"
      "29"
      "30"
      "31"
      "32"
      "33"
      "34"
      "35"
    ];
    includeEmulator = "if-supported";
    includeSystemImages = "if-supported";
    includeNDK = "if-supported";
  };

  test-suite = pkgs.callPackage ./test-suite.nix {
    inherit meta;
  };

  inherit (test-suite) passthru;

  meta = {
    homepage = "https://developer.android.com/tools";
    description = "Android SDK tools, packaged in Nixpkgs";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      numinit
      hadilq
    ];
  };
}
