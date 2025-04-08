{
  lib,
  stdenv,
  fetchFromGitHub,
  libpq,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libpqxx";
  version = "7.10.0";

  src = fetchFromGitHub {
    owner = "jtv";
    repo = "libpqxx";
    tag = finalAttrs.version;
    hash = "sha256-llsnd1bxAyiEgo9PfWYdQp1RPPk1oF/02IgMvPhodZ0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    libpq
  ];

  postPatch = ''
    patchShebangs ./tools/splitconfig.py
  '';

  configureFlags = [
    "--disable-documentation"
    "--enable-shared"
  ];

  strictDeps = true;

  meta = {
    changelog = "https://github.com/jtv/libpqxx/releases/tag/${finalAttrs.version}";
    description = "C++ library to access PostgreSQL databases";
    downloadPage = "https://github.com/jtv/libpqxx";
    homepage = "https://pqxx.org/development/libpqxx/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
