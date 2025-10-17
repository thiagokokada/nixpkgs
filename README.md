# Hey this is just a fork!

You're probably looking for [the upstream
repo](https://github.com/NixOS/nixpkgs).

The actual branches from upstream are
[`master`](https://github.com/thiagokokada/nixpkgs/tree/master),
[`staging`](https://github.com/thiagokokada/nixpkgs/tree/staging) and
[`staging-nixos`](https://github.com/thiagokokada/nixpkgs/tree/staging-nixos).

This branch include my automation to help keep the branches above up to date
(see [sync-fork](./actions/sync-fork.nix)).

It is [all generated from
Nix](https://kokada.dev/blog/generating-yaml-files-with-nix/) instead of
writing YAML directly. The reason for this is that the limitations of YAML
become annoying eventually. There is no documentation, but you can take a look
at the source code. If you just want to re-generate the files, you can run:

```console
nix run .#generate-gh-actions
```

## If you want to replicate this

I recommend forking the upstream repo instead of this one so Pull Requests are
opened against the actual upstream. You can freely copy the code of this branch
(check [LICENSE](./LICENSE)). Keep in mind that the other branches have their
own license!

You can create a branch without parent in Git by using:

```console
git checkout --orphan fork
```

To setup the actions, you will need to setup 3 secrets:

- `GITHUB_TOKEN`: I recommend a PAT classic token with `repo` and `workflow`
  permissions
