{
  # If you copy this example out of nixpkgs, use these lines instead of the next.
  # This example pins nixpkgs: https://nix.dev/tutorials/first-steps/towards-reproducibility-pinning-nixpkgs.html
  /*
    nixpkgsSource ? (builtins.fetchTarball {
      name = "nixpkgs-20.09";
      url = "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz";
      sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";
    }),
    pkgs ? import nixpkgsSource {
      config.allowUnfree = true;
    },
  */

  # If you want to use the in-tree version of nixpkgs:
  pkgs ? import ../../../../.. {
    config.allowUnfree = true;
  },

  # You probably need to set it to true to express consent.
  licenseAccepted ? pkgs.callPackage ../license.nix { },
}:

# Copy this file to your Android project.
let
  # If you copy this example out of nixpkgs, something like this will work:
  /*
    androidEnvNixpkgs = fetchTarball {
      name = "androidenv";
      url = "https://github.com/NixOS/nixpkgs/archive/<fill me in from Git>.tar.gz";
      sha256 = "<fill me in with nix-prefetch-url --unpack>";
    };

    androidEnv = pkgs.callPackage "${androidEnvNixpkgs}/pkgs/development/mobile/androidenv" {
      inherit pkgs;
      licenseAccepted = true;
    };
  */

  # Otherwise, just use the in-tree androidenv:
  androidEnv = pkgs.callPackage ./.. {
    inherit pkgs licenseAccepted;
  };

  # The head unit only works on these platforms
  includeAuto = pkgs.stdenv.hostPlatform.isx86_64 || pkgs.stdenv.hostPlatform.isDarwin;

  androidComposition = androidEnv.composeAndroidPackages {
    includeSources = true;
    includeSystemImages = true;
    includeEmulator = "if-supported";
    includeNDK = "if-supported";
    useGoogleAPIs = true;

    platformVersions = [
      "23"
      "24"
      "25"
      "26"
      "27"
      "28"
      "29"
      "30"
      "31"
      "32"
      "33"
      "34"
      "35"
    ];

    # If you want to use a custom repo JSON:
    # repoJson = ../repo.json;

    # If you want to use custom repo XMLs:
    /*
      repoXmls = {
        packages = [ ../xml/repository2-1.xml ];
        images = [
          ../xml/android-sys-img2-1.xml
          ../xml/android-tv-sys-img2-1.xml
          ../xml/android-wear-sys-img2-1.xml
          ../xml/android-wear-cn-sys-img2-1.xml
          ../xml/google_apis-sys-img2-1.xml
          ../xml/google_apis_playstore-sys-img2-1.xml
        ];
        addons = [ ../xml/addon2-1.xml ];
      };
    */

    includeExtras =
      [
        "extras;google;gcm"
      ]
      ++ pkgs.lib.optionals includeAuto [
        "extras;google;auto"
      ];

    # Accepting more licenses declaratively:
    extraLicenses = [
      # Already accepted for you with the global accept_license = true or
      # licenseAccepted = true on androidenv.
      # "android-sdk-license"

      # These aren't, but are useful for more uncommon setups.
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;
  platformTools = androidComposition.platform-tools;
  jdk = pkgs.jdk;
in
pkgs.mkShell rec {
  name = "androidenv-demo";
  packages = [
    androidSdk
    platformTools
    jdk
  ];

  LANG = "C.UTF-8";
  LC_ALL = "C.UTF-8";
  JAVA_HOME = jdk.home;

  # Note: ANDROID_HOME is deprecated. Use ANDROID_SDK_ROOT.
  ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";

  shellHook = ''
    # Ensures that we don't have to use a FHS env by using the nix store's aapt2.
    export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$(echo "$ANDROID_SDK_ROOT/build-tools/"*"/aapt2")"

    # Add cmake to the path.
    cmake_root="$(echo "$ANDROID_SDK_ROOT/cmake/"*/)"
    export PATH="$cmake_root/bin:$PATH"

    # Write out local.properties for Android Studio.
    cat <<EOF > local.properties
    # This file was automatically generated by nix-shell.
    sdk.dir=$ANDROID_SDK_ROOT
    ndk.dir=$ANDROID_NDK_ROOT
    cmake.dir=$cmake_root
    EOF
  '';

  passthru.tests = {

    shell-sdkmanager-licenses-test =
      pkgs.runCommand "shell-sdkmanager-licenses-test"
        {
          nativeBuildInputs = [
            androidSdk
            jdk
          ];
        }
        ''
          if [[ ! "$(sdkmanager --licenses)" =~ "All SDK package licenses accepted." ]]; then
            echo "At least one of SDK package licenses are not accepted."
            exit 1
          fi
          touch $out
        '';

    shell-sdkmanager-packages-test =
      pkgs.runCommand "shell-sdkmanager-packages-test"
        {
          nativeBuildInputs = [
            androidSdk
            jdk
          ];
        }
        ''
          output="$(sdkmanager --list)"
          installed_packages_section=$(echo "''${output%%Available Packages*}" | awk 'NR>4 {print $1}')

          # FIXME couldn't find platforms;android-34, even though it's in the correct directory!! sdkmanager's bug?!
          packages=(
            "build-tools" "platform-tools" \
            "platforms;android-23" "platforms;android-24" "platforms;android-25" "platforms;android-26" \
            "platforms;android-27" "platforms;android-28" "platforms;android-29" "platforms;android-30" \
            "platforms;android-31" "platforms;android-32" "platforms;android-33" "platforms;android-35" \
            "sources;android-23" "sources;android-24" "sources;android-25" "sources;android-26" \
            "sources;android-27" "sources;android-28" "sources;android-29" "sources;android-30" \
            "sources;android-31" "sources;android-32" "sources;android-33" "sources;android-34" \
            "sources;android-35" \
            "system-images;android-28;google_apis_playstore;x86_64" \
            "system-images;android-29;google_apis_playstore;x86_64" \
            "system-images;android-30;google_apis_playstore;x86_64" \
            "system-images;android-31;google_apis_playstore;x86_64" \
            "system-images;android-32;google_apis_playstore;x86_64" \
            "system-images;android-33;google_apis_playstore;x86_64" \
            "system-images;android-34;google_apis;x86_64" \
            "system-images;android-35;google_apis;x86_64" \
            "extras;google;gcm"
          )
          ${pkgs.lib.optionalString includeAuto ''packages+=("extras;google;auto")''}

          for package in "''${packages[@]}"; do
            if [[ ! $installed_packages_section =~ "$package" ]]; then
              echo "$package package was not installed."
              exit 1
            fi
          done

          touch "$out"
        '';
  };
}
