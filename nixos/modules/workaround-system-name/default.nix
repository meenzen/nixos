/*
 Last reviewied: 2024-05-29

fixes issues with lack of HTTP header sanitization in .NET Core, see:
- https://github.com/NixOS/nixpkgs/issues/315574
- https://github.com/microsoftgraph/msgraph-cli/issues/477

Stolen from https://github.com/nazarewk-iac/nix-configs/commit/5a76297893bbb171c440da90fb5e417bf9993bfe#diff-9bd1903895edc8ec69ce6debf7823905ba99fa41c35d4482d0464ab7f47aa627
*/
{
  lib,
  options,
  ...
}: {
  options.system.nixos.codeName = lib.mkOption {readOnly = false;};
  config.system.nixos.codeName = let
    codeName = options.system.nixos.codeName.default;
    renames."Vicuña" = "Vicuna";
  in
    renames."${codeName}" or (throw "Unknown `codeName`: ${codeName}");
}
