{ lib }:
{
  escapeGhVar = var: "\${{ ${var} }}";

  recursiveMergeAttrs = builtins.foldl' lib.recursiveUpdate { };
}
