{
  callPackage,
  kernel ? null,
  stdenv,
  nixosTests,
  ...
}@args:

let
  stdenv' = if kernel == null then stdenv else kernel.stdenv;
in
callPackage ./generic.nix args {
  # You have to ensure that in `pkgs/top-level/linux-kernels.nix`
  # this attribute is the correct one for this package.
  kernelModuleAttribute = "zfs_unstable";
  # check the release notes for compatible kernels
  kernelCompatible = kernel: kernel.kernelOlder "6.14";

  # this package should point to a version / git revision compatible with the latest kernel release
  # IMPORTANT: Always use a tagged release candidate or commits from the
  # zfs-<version>-staging branch, because this is tested by the OpenZFS
  # maintainers.
  version = "2.3.1";
  # rev = "";

  tests = {
    inherit (nixosTests.zfs) unstable;
  };

  hash = "sha256-3WrxjIMuPiqBcVX4UZHpcMWNqxBE2NS810SRmvi05ZQ=";

  extraLongDescription = ''
    This is "unstable" ZFS, and will usually be a pre-release version of ZFS.
    It may be less well-tested and have critical bugs.
  '';
}
