# Hey this is just a fork!

You're probably looking for [the upstream
repo](https://github.com/NixOS/nixpkgs).

The actual branches from upstream are
[`master`](https://github.com/thiagokokada/nixpkgs/tree/master) and
[`staging`](https://github.com/thiagokokada/nixpkgs/tree/staging).

This branch includes some of my automation to help keep the branches above up
to date (see [sync-fork](./actions/sync-fork.nix)) and also a way to run
[nixpkgs-review](https://github.com/Mic92/nixpkgs-review) for a PR in upstream
inside GitHub Actions (see [nixpkgs-review](./actions/nixpkgs-review.nix)).

It is [all generated from
Nix](https://kokada.dev/blog/generating-yaml-files-with-nix/) instead of
writing YAML directly. The reason for this is that the limitations of YAML
become annoying eventually. There is no documentation, but you can take a look
at the source code. If you just want to re-generate the files, you can run:

```console
nix run .#generate-gh-actions
```
