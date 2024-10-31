{ lib, stdenv, fetchurl, darwin, pkg-config, perl, nixosTests
, brotliSupport ? false, brotli
, c-aresSupport ? false, c-aresMinimal
, gnutlsSupport ? false, gnutls
, gsaslSupport ? false, gsasl
, gssSupport ? with stdenv.hostPlatform; (
    !isWindows &&
    # disable gss because of: undefined reference to `k5_bcmp'
    # a very sad story re static: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=439039
    !isStatic &&
    # the "mig" tool does not configure its compiler correctly. This could be
    # fixed in mig, but losing gss support on cross compilation to darwin is
    # not worth the effort.
    !(isDarwin && (stdenv.buildPlatform != stdenv.hostPlatform))
  ), libkrb5
, http2Support ? true, nghttp2
, http3Support ? false, nghttp3, ngtcp2
, websocketSupport ? false
, idnSupport ? false, libidn2
, ldapSupport ? false, openldap
, opensslSupport ? zlibSupport, openssl
, pslSupport ? false, libpsl
, rtmpSupport ? false, rtmpdump
, scpSupport ? zlibSupport && !stdenv.hostPlatform.isSunOS && !stdenv.hostPlatform.isCygwin, libssh2
, wolfsslSupport ? false, wolfssl
, rustlsSupport ? false, rustls-ffi
, zlibSupport ? true, zlib
, zstdSupport ? false, zstd

# for passthru.tests
, coeurl
, curlpp
, haskellPackages
, ocamlPackages
, phpExtensions
, pkgsStatic
, python3
, tests
, testers
, fetchpatch
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

assert !((lib.count (x: x) [ gnutlsSupport opensslSupport wolfsslSupport rustlsSupport ]) > 1);

stdenv.mkDerivation (finalAttrs: {
  pname = "curl";
  version = "8.10.1";

  src = fetchurl {
    urls = [
      "https://curl.haxx.se/download/curl-${finalAttrs.version}.tar.xz"
      "https://github.com/curl/curl/releases/download/curl-${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}/curl-${finalAttrs.version}.tar.xz"
    ];
    hash = "sha256-c6Sw6ZWWoJ+lkkpPt+S5lahf2g0YosAquc8TS+vOBO4=";
  };

  # this could be accomplished by updateAutotoolsGnuConfigScriptsHook, but that causes infinite recursion
  # necessary for FreeBSD code path in configure
  postPatch = ''
    substituteInPlace ./config.guess --replace-fail /usr/bin/uname uname
    patchShebangs scripts
  '';

  outputs = [ "bin" "dev" "out" "man" "devdoc" ];
  separateDebugInfo = stdenv.hostPlatform.isLinux;

  enableParallelBuilding = true;

  strictDeps = true;

  env = lib.optionalAttrs (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isStatic) {
    # Not having this causes curl’s `configure` script to fail with static builds on Darwin because
    # some of curl’s propagated inputs need libiconv.
    NIX_LDFLAGS = "-liconv";
  };

  nativeBuildInputs = [ pkg-config perl ];

  # Zlib and OpenSSL must be propagated because `libcurl.la' contains
  # "-lz -lssl", which aren't necessary direct build inputs of
  # applications that use Curl.
  propagatedBuildInputs =
    lib.optional brotliSupport brotli ++
    lib.optional c-aresSupport c-aresMinimal ++
    lib.optional gnutlsSupport gnutls ++
    lib.optional gsaslSupport gsasl ++
    lib.optional gssSupport libkrb5 ++
    lib.optional http2Support nghttp2 ++
    lib.optionals http3Support [ nghttp3 ngtcp2 ] ++
    lib.optional idnSupport libidn2 ++
    lib.optional ldapSupport openldap ++
    lib.optional opensslSupport openssl ++
    lib.optional pslSupport libpsl ++
    lib.optional rtmpSupport rtmpdump ++
    lib.optional scpSupport libssh2 ++
    lib.optional wolfsslSupport wolfssl ++
    lib.optional rustlsSupport rustls-ffi ++
    lib.optional zlibSupport zlib ++
    lib.optional zstdSupport zstd ++
    lib.optionals stdenv.hostPlatform.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreFoundation
      CoreServices
      SystemConfiguration
    ]);

  # for the second line see https://curl.haxx.se/mail/tracker-2014-03/0087.html
  preConfigure = ''
    sed -e 's|/usr/bin|/no-such-path|g' -i.bak configure
    rm src/tool_hugehelp.c
  '' + lib.optionalString (pslSupport && stdenv.hostPlatform.isStatic) ''
    # curl doesn't understand that libpsl2 has deps because it doesn't use
    # pkg-config.
    # https://github.com/curl/curl/pull/12919
    configureFlagsArray+=("LIBS=-lidn2 -lunistring")
  '';

  configureFlags = [
      "--enable-versioned-symbols"
      # Build without manual
      "--disable-manual"
      (lib.enableFeature c-aresSupport "ares")
      (lib.enableFeature ldapSupport "ldap")
      (lib.enableFeature ldapSupport "ldaps")
      (lib.enableFeature websocketSupport "websockets")
      # --with-ca-fallback is only supported for openssl and gnutls https://github.com/curl/curl/blame/curl-8_0_1/acinclude.m4#L1640
      (lib.withFeature (opensslSupport || gnutlsSupport) "ca-fallback")
      (lib.withFeature http3Support "nghttp3")
      (lib.withFeature http3Support "ngtcp2")
      (lib.withFeature rtmpSupport "librtmp")
      (lib.withFeature rustlsSupport "rustls")
      (lib.withFeature zstdSupport "zstd")
      (lib.withFeature pslSupport "libpsl")
      (lib.withFeatureAs brotliSupport "brotli" (lib.getDev brotli))
      (lib.withFeatureAs gnutlsSupport "gnutls" (lib.getDev gnutls))
      (lib.withFeatureAs idnSupport "libidn2" (lib.getDev libidn2))
      (lib.withFeatureAs opensslSupport "openssl" (lib.getDev openssl))
      (lib.withFeatureAs scpSupport "libssh2" (lib.getDev libssh2))
      (lib.withFeatureAs wolfsslSupport "wolfssl" (lib.getDev wolfssl))
    ]
    ++ lib.optional gssSupport "--with-gssapi=${lib.getDev libkrb5}"
       # For the 'urandom', maybe it should be a cross-system option
    ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform)
       "--with-random=/dev/urandom"
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # Disable default CA bundle, use NIX_SSL_CERT_FILE or fallback to nss-cacert from the default profile.
      # Without this curl might detect /etc/ssl/cert.pem at build time on macOS, causing curl to ignore NIX_SSL_CERT_FILE.
      "--without-ca-bundle"
      "--without-ca-path"
    ] ++ lib.optionals (!gnutlsSupport && !opensslSupport && !wolfsslSupport && !rustlsSupport) [
      "--without-ssl"
    ] ++ lib.optionals (rustlsSupport && !stdenv.hostPlatform.isDarwin) [
      "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    ] ++ lib.optionals (gnutlsSupport && !stdenv.hostPlatform.isDarwin) [
      "--with-ca-path=/etc/ssl/certs"
    ];

  CXX = "${stdenv.cc.targetPrefix}c++";
  CXXCPP = "${stdenv.cc.targetPrefix}c++ -E";

  # takes 14 minutes on a 24 core and because many other packages depend on curl
  # they cannot be run concurrently and are a bottleneck
  # tests are available in passthru.tests.withCheck
  doCheck = false;
  preCheck = ''
    patchShebangs tests/
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # bad interaction with sandbox if enabled?
    rm tests/data/test1453
    rm tests/data/test1086
  '' + lib.optionalString stdenv.hostPlatform.isMusl ''
    # different resolving behaviour?
    rm tests/data/test1592
  '';

  postInstall = ''
    moveToOutput bin/curl-config "$dev"

    # Install completions
    make -C scripts install
  '' + lib.optionalString scpSupport ''
    sed '/^dependency_libs/s|${lib.getDev libssh2}|${lib.getLib libssh2}|' -i "$out"/lib/*.la
  '' + lib.optionalString gnutlsSupport ''
    ln $out/lib/libcurl${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/libcurl-gnutls${stdenv.hostPlatform.extensions.sharedLibrary}
    ln $out/lib/libcurl${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/libcurl-gnutls${stdenv.hostPlatform.extensions.sharedLibrary}.4
    ln $out/lib/libcurl${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/libcurl-gnutls${stdenv.hostPlatform.extensions.sharedLibrary}.4.4.0
  '';

  passthru = let
    useThisCurl = attr: attr.override { curl = finalAttrs.finalPackage; };
  in {
    inherit opensslSupport openssl;
    tests = {
      withCheck = finalAttrs.finalPackage.overrideAttrs (_: { doCheck = true; });
      fetchpatch = tests.fetchpatch.simple.override { fetchpatch = (fetchpatch.override { fetchurl = useThisCurl fetchurl; }) // { version = 1; }; };
      curlpp = useThisCurl curlpp;
      coeurl = useThisCurl coeurl;
      haskell-curl = useThisCurl haskellPackages.curl;
      ocaml-curly = useThisCurl ocamlPackages.curly;
      pycurl = useThisCurl python3.pkgs.pycurl;
      php-curl = useThisCurl phpExtensions.curl;
      # error: attribute 'override' missing
      # Additional checking with support http3 protocol.
      # nginx-http3 = useThisCurl nixosTests.nginx-http3;
      nginx-http3 = nixosTests.nginx-http3;
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
      static = pkgsStatic.curl;
    };
  };

  meta = {
    changelog = "https://curl.se/ch/${finalAttrs.version}.html";
    description = "Command line tool for transferring files with URL syntax";
    homepage    = "https://curl.se/";
    license = lib.licenses.curl;
    maintainers = with lib.maintainers; [ lovek323 ];
    platforms = lib.platforms.all;
    # Fails to link against static brotli or gss
    broken = stdenv.hostPlatform.isStatic && (brotliSupport || gssSupport);
    pkgConfigModules = [ "libcurl" ];
    mainProgram = "curl";
  };
})
