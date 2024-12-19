{ ... }:
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
    ];
    runs-on = "ubuntu-latest";
    steps = [
      {
        uses = "thiagokokada/merge-upstream@v1.0.2";
        "with" = {
          branch = ''''${{ matrix.branch }}'';
          token = ''''${{ secrets.PAT_TOKEN }}'';
        };
      }
    ];
  };
}
