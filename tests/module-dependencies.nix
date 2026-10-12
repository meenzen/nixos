# Enables every meenzen.*.enable option on its own in an otherwise empty system and fails if the module uses nginx,
# PostgreSQL or OCI containers without enabling the corresponding meenzen module, which configures firewall, ACME,
# backups, tuning and so on. Hosts that happen to enable those modules themselves would hide the missing dependency.
{
  pkgs,
  self,
}: let
  inherit (pkgs) lib;

  base = self.lib.mkSystem {
    nixpkgs.hostPlatform = pkgs.stdenv.hostPlatform.system;
    networking.hostName = "module-dependencies";
    fileSystems."/".device = "none";
    boot.loader.grub.enable = false;
    system.stateVersion = "26.05";
  };

  enableOptions = path: options:
    lib.concatLists (lib.mapAttrsToList (name: value:
      if lib.isOption value
      then lib.optional (name == "enable") path
      else if builtins.isAttrs value
      then enableOptions (path ++ [name]) value
      else [])
    options);

  missingDependencies = path: let
    inherit ((base.extendModules {modules = [{meenzen = lib.setAttrByPath (path ++ ["enable"]) true;}];})) config;
  in
    lib.optional
    # nixpkgs always defines the localhost virtual host
    ((config.services.nginx.enable || builtins.removeAttrs config.services.nginx.virtualHosts ["localhost"] != {})
      && !config.meenzen.nginx.enable)
    "meenzen.nginx"
    ++ lib.optional (config.services.postgresql.enable && !config.meenzen.postgresql.enable) "meenzen.postgresql"
    ++ lib.optional (config.virtualisation.oci-containers.containers != {} && !config.meenzen.oci-containers.enable)
    "meenzen.oci-containers";

  failures = lib.concatMap (path: let
    missing = missingDependencies path;
  in
    lib.optional (missing != [])
    "meenzen.${lib.concatStringsSep "." path}.enable doesn't enable ${lib.concatStringsSep ", " missing}") (enableOptions [] base.options.meenzen);
in
  pkgs.runCommand "module-dependencies" {
    failures = lib.concatStringsSep "\n" failures;
  } (
    if failures == []
    then "touch $out"
    else ''
      echo "$failures" >&2
      exit 1
    ''
  )
