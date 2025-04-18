{ lib }:
let
  recursiveMergeAttrs = builtins.foldl' lib.recursiveUpdate { };
in
{
  name = "nixpkgs-review PR";
  run-name = ''nixpkgs-review for PR ''${{ github.event.inputs.pr }}'';
  on = {
    workflow_dispatch = {
      inputs =
        let
          archOpt = arch: {
            "build-on-${arch}" = {
              type = "boolean";
              description = "Build on ${arch}";
              default = true;
              required = true;
            };
          };
        in
        {
          pr = {
            description = "PR number";
            type = "string";
            required = true;
          };
          extra-args = {
            description = "Extra args for nixpkgs-review";
            type = "string";
            default = "";
            required = false;
          };
          branch = {
            description = "Nixpkgs branch";
            type = "choice";
            default = "master";
            options = [
              "master"
              "staging"
            ];
          };
          free-space = {
            description = "Run workflow to increase free space";
            type = "boolean";
            default = false;
            required = true;
          };
        }
        // (archOpt "x86_64-linux")
        // (archOpt "aarch64-darwin")
        // (archOpt "x86_64-darwin");
    };
  };

  concurrency = {
    group = ''review-''${{ github.event.inputs.pr }}'';
    cancel-in-progress = true;
  };

  env = {
    GITHUB_TOKEN = ''''${{ secrets.PAT_TOKEN }}'';
    PR = ''''${{ github.event.inputs.pr }}'';
    EXTRA_ARGS = ''''${{ github.event.inputs.extra-args }}'';
  };

  jobs =
    let
      stepName = arg: "build-${arg.arch}";
      nixpkgsReviewForArch =
        {
          arch,
          runs-on,
          enable-free-disk ? false,
        }@args:
        {
          ${stepName args} = {
            inherit runs-on;
            name = ''nixpkgs-review for PR ''${{ github.event.inputs.pr }} on ${arch}'';
            "if" = ''''${{ github.event.inputs.build-on-${arch} == 'true' }}'';
            outputs.built = ''''${{ steps.output.outputs.built }}'';

            steps = (
              builtins.filter (s: s != { }) [
                (lib.optionalAttrs enable-free-disk {
                  uses = "thiagokokada/free-disk-space@main";
                  "if" = ''''${{ github.event.inputs.free-space == 'true' }}'';
                })
                {
                  uses = "actions/cache@v4";
                  "with" = {
                    path = "nixpkgs";
                    key = "git-folder";
                  };
                }
                {
                  uses = "actions/checkout@v4";
                  "with" = {
                    path = "nixpkgs";
                    ref = ''''${{ github.event.inputs.branch }}'';
                    fetch-depth = 0;
                  };
                }
                { uses = "DeterminateSystems/nix-installer-action@v16"; }
                {
                  name = "Configure git";
                  run = ''
                    git config --global user.email "user@example.com"
                    git config --global user.name "user"
                  '';
                }
                {
                  name = "Run review";
                  continue-on-error = true;
                  run = ''
                    cd "$GITHUB_WORKSPACE/nixpkgs"
                    # shellcheck disable=SC2086
                    nix run .#nixpkgs-review -- pr "''${PR//[^0-9]/}" --print-result --post-result --no-shell $EXTRA_ARGS
                  '';
                }
                {
                  name = "Output";
                  id = "output";
                  run = ''
                    built=$(jq -r '.result[].built | join(", ")' ~/.cache/nixpkgs-review/*/report.json)
                    echo "built=$built" | tee -a "$GITHUB_OUTPUT"
                  '';
                }
                {
                  uses = "actions/upload-artifact@v4";
                  "with" = {
                    name = "build-logs-${arch}";
                    path = ''
                      /nix/var/log/*/drvs
                      ~/.cache/nixpkgs-review/*/logs
                    '';
                    include-hidden-files = true;
                  };
                }
              ]
            );
          };
        };
      args = [
        {
          arch = "x86_64-linux";
          runs-on = "ubuntu-latest";
          enable-free-disk = true;
        }
        {
          arch = "aarch64-darwin";
          runs-on = "macos-latest";
        }
        {
          arch = "x86_64-darwin";
          runs-on = "macos-13";
        }
      ];
    in
    recursiveMergeAttrs (builtins.map nixpkgsReviewForArch args)
    // {
      notify = {
        name = "Notify Telegram";
        needs = builtins.map stepName args;
        runs-on = "ubuntu-latest";
        "if" = "always()"; # Ensures this job runs even if others fail
        steps = [
          {
            id = "pre_notify";
            run = ''
              echo "pr_link=https://github.com/NixOS/nixpkgs/pull/''${PR//[^0-9]/}" | tee -a "$GITHUB_OUTPUT"
            '';
          }
          {
            uses = "appleboy/telegram-action@v1.0.1";
            "with" = {
              to = ''''${{ secrets.TELEGRAM_TO }}'';
              token = ''''${{ secrets.TELEGRAM_TOKEN }}'';
              message =
                ''
                  Finished nixpkgs-review for PR: ''${{ steps.pre_notify.outputs.pr_link }}

                  Run report: https://github.com/''${{ github.repository }}/actions/runs/''${{ github.run_id }}

                  Packages built:
                ''
                + lib.concatStringsSep "\n" (
                  builtins.map (a: ''- ${a.arch}: ''${{ needs.${stepName a}.outputs.built }}'') args
                );
            };
          }
        ];
      };
    };
}
