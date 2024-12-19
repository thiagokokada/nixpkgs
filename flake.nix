{
  description = "Nixpkgs repo helpers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-linux"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          mkGHActionsYAML =
            name:
            pkgs.runCommand name
              {
                buildInputs = with pkgs; [
                  action-validator
                  yj
                ];
                json = builtins.toJSON (import ./actions/${name}.nix);
                passAsFile = [ "json" ];
              }
              ''
                mkdir -p $out
                yj -jy < "$jsonPath" > $out/${name}.yml
                action-validator -v $out/${name}.yml
              '';
          ghActionsYAMLs = map mkGHActionsYAML [ "nixpkgs-review" ];
        in
        {
          generate-gh-actions = pkgs.writeShellScriptBin "generate-gh-actions" ''
            for dir in ${builtins.toString ghActionsYAMLs}; do
              cp -f $dir/*.yml .github/workflows/
            done
            echo Done!
          '';
        }
      );
    };
}
