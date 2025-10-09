{ lib, ... }:
let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) escapeGhVar;
in
{
  name = "Sync fork with upstream";
  on = {
    schedule = [ { cron = "0 */6 * * *"; } ];
    workflow_dispatch = null;
  };

  jobs.sync-fork = {
    strategy.matrix.branch = [
      "master"
      "staging"
      "staging-nixos"
    ];
    runs-on = "ubuntu-latest";
    steps = [
      {
        uses = "thiagokokada/merge-upstream@v1.0.2";
        "with" = {
          branch = escapeGhVar "matrix.branch";
          token = escapeGhVar "secrets.PAT_TOKEN";
        };
      }
    ];
  };
}
