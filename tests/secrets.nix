# Fails if secrets/ contains a secret that no host uses, or if a rule in agenix-rules.nix and its .age file don't both
# exist. Unused secrets are easy to miss when removing a service and still have to be rekeyed whenever a key changes.
{
  pkgs,
  self,
}: let
  inherit (pkgs) lib;

  used = lib.unique (lib.concatMap (system:
    lib.mapAttrsToList (_: secret: builtins.unsafeDiscardStringContext (baseNameOf (toString secret.file)))
    (lib.filterAttrs (_: secret: secret.enable) system.config.age.secrets))
  (lib.attrValues self.nixosConfigurations));
  rules = builtins.attrNames (import ../secrets/agenix-rules.nix);
  files = builtins.filter (lib.hasSuffix ".age") (builtins.attrNames (builtins.readDir ../secrets));

  failures =
    map (file: "${file} is not used by any host") (lib.subtractLists used rules)
    ++ map (file: "${file} has no rule in agenix-rules.nix") (lib.subtractLists rules files)
    ++ map (file: "${file} has a rule in agenix-rules.nix, but the file doesn't exist") (lib.subtractLists files rules);
in
  pkgs.runCommand "secrets" {
    failures = lib.concatStringsSep "\n" failures;
  } (
    if failures == []
    then "touch $out"
    else ''
      echo "$failures" >&2
      exit 1
    ''
  )
