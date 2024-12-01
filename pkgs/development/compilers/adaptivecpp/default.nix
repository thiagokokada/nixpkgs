{
  lib,
  fetchFromGitHub,
  llvmPackages_17,
  lld_17,
  python3,
  cmake,
  boost,
  libxml2,
  libffi,
  makeWrapper,
  config,
  cudaPackages,
  rocmPackages_6,
  ompSupport ? true,
  openclSupport ? false,
  rocmSupport ? config.rocmSupport,
  cudaSupport ? config.cudaSupport,
  autoAddDriverRunpath,
}:
let
  inherit (llvmPackages) stdenv;
  rocmPackages = rocmPackages_6;
  llvmPackages = llvmPackages_17;
  lld = lld_17;
in
stdenv.mkDerivation rec {
  pname = "adaptivecpp";
  version = "24.06.0";

  src = fetchFromGitHub {
    owner = "AdaptiveCpp";
    repo = "AdaptiveCpp";
    rev = "v${version}";
    sha256 = "sha256-TPa2DT66bGQ9VfSXaFUDuE5ng5x5fiLC2bqQ+ZVo9LQ=";
  };

  nativeBuildInputs =
    [
      cmake
      makeWrapper
    ]
    ++ lib.optionals cudaSupport [
      autoAddDriverRunpath
      cudaPackages.cuda_nvcc
    ];

  buildInputs =
    [
      libxml2
      libffi
      boost
      llvmPackages.openmp
      llvmPackages.libclang.dev
      llvmPackages.llvm
    ]
    ++ lib.optionals rocmSupport [
      rocmPackages.clr
      rocmPackages.rocm-runtime
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_cudart
      (lib.getOutput "stubs" cudaPackages.cuda_cudart)
    ];

  # adaptivecpp makes use of clangs internal headers. Its cmake does not successfully discover them automatically on nixos, so we supply the path manually
  cmakeFlags =
    [
      "-DCLANG_INCLUDE_PATH=${llvmPackages.libclang.dev}/include"
      (lib.cmakeBool "WITH_CPU_BACKEND" ompSupport)
      (lib.cmakeBool "WITH_CUDA_BACKEND" cudaSupport)
      (lib.cmakeBool "WITH_ROCM_BACKEND" rocmSupport)
    ]
    ++ lib.optionals (lib.versionAtLeast version "24") [
      (lib.cmakeBool "WITH_OPENCL_BACKEND" openclSupport)
    ];

  # this hardening option breaks rocm builds
  hardeningDisable = [ "zerocallusedregs" ];

  postFixup =
    ''
      wrapProgram $out/bin/syclcc-clang \
        --prefix PATH : ${
          lib.makeBinPath [
            python3
            lld
          ]
        } \
        --add-flags "-L${llvmPackages.openmp}/lib" \
        --add-flags "-I${llvmPackages.openmp.dev}/include" \
    ''
    + lib.optionalString rocmSupport ''
      --add-flags "--rocm-device-lib-path=${rocmPackages.rocm-device-libs}/amdgcn/bitcode"
    '';

  meta = with lib; {
    homepage = "https://github.com/AdaptiveCpp/AdaptiveCpp";
    description = "Multi-backend implementation of SYCL for CPUs and GPUs";
    maintainers = with maintainers; [ yboettcher ];
    license = licenses.bsd2;
  };
}
