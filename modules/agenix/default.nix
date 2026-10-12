{
  config,
  inputs,
  lib,
  secrets,
  ...
}: let
  enabledSecrets = lib.filterAttrs (_: secret: secret.enable) config.age.secrets;

  isInStore = secret: lib.hasPrefix "${builtins.storeDir}/" (toString secret.file);

  # agenix decrypts every secret to a stable path, so units referencing it don't change when only the secret's content
  # changes. Hash the encrypted file instead of using its path: the path is inside a store copy of the whole repository
  # and changes whenever anything changes. Tests may use secret files outside the store that don't exist.
  trigger = secret:
    if isInStore secret
    then builtins.hashFile "sha256" secret.file
    else toString secret.file;

  unitsOption = action:
    lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["podman-foo.service"];
      description = "Services to ${action} when the secret changes.";
    };

  triggers = unitsAttr: mkTriggers:
    lib.mkMerge (lib.mapAttrsToList (_: secret:
      lib.genAttrs (map (lib.removeSuffix ".service") secret.${unitsAttr}) (name: mkTriggers name [(trigger secret)]))
    enabledSecrets);

  # With reloadIfChanged, every change of the unit reloads it, so restartTriggers already reload it. Setting
  # reloadTriggers as well causes an evaluation warning.
  reloadTriggers = name: value: let
    inherit (config.systemd.services.${name}) reloadIfChanged;
  in {
    restartTriggers = lib.mkIf reloadIfChanged value;
    reloadTriggers = lib.mkIf (!reloadIfChanged) value;
  };

  isId = value: builtins.match "[0-9]+" value != null;

  rules = import "${secrets}/agenix-rules.nix";
  hostKey = (import "${secrets}/hosts.nix").${config.networking.hostName} or null;

  # Otherwise agenix fails to decrypt the secrets during activation. Tests use their own secret files.
  decryptAssertions = lib.optionals (!config.meenzen.test-setup.enable && enabledSecrets != {}) (
    [
      {
        assertion = hostKey != null;
        message = "secrets/hosts.nix has no host key for ${config.networking.hostName}, which uses age secrets.";
      }
    ]
    ++ lib.mapAttrsToList (secretName: secret: let
      file = builtins.unsafeDiscardStringContext (baseNameOf (toString secret.file));
    in {
      assertion = hostKey == null || lib.elem hostKey (rules.${file}.publicKeys or []);
      message = "age.secrets.${secretName}.file is `${file}`, which secrets/agenix-rules.nix does not encrypt for ${config.networking.hostName}.";
    })
    enabledSecrets
  );

  # The triggers above define every listed service, so a typo would silently create an empty unit instead of failing.
  hasServiceConfig = key: unit: let
    name = lib.removeSuffix ".service" unit;
  in
    lib.hasSuffix ".service" unit && (config.systemd.services.${name}.serviceConfig.${key} or null) != null;

  unitAssertions = unitsAttr: key:
    lib.concatLists (lib.mapAttrsToList (secretName: secret:
      map (unit: {
        assertion = hasServiceConfig key unit;
        message = "age.secrets.${secretName}.${unitsAttr} contains `${unit}`, which is not a service with ${key}.";
      })
      secret.${unitsAttr})
    enabledSecrets);
in {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  options.age.secrets = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        restartUnits = unitsOption "restart";
        reloadUnits = unitsOption "reload";
      };
    });
  };

  config = {
    assertions =
      unitAssertions "restartUnits" "ExecStart"
      ++ unitAssertions "reloadUnits" "ExecReload"
      ++ decryptAssertions
      # Outside the store the trigger is the constant path, so the units would never be restarted or reloaded.
      ++ lib.mapAttrsToList (secretName: secret: {
        assertion = config.meenzen.test-setup.enable || isInStore secret || secret.restartUnits ++ secret.reloadUnits == [];
        message = "age.secrets.${secretName}.file must be in the Nix store to restart or reload units, but is `${toString secret.file}`.";
      })
      enabledSecrets
      # Otherwise agenix fails to chown the secret during activation and the service can't read it.
      ++ lib.concatLists (lib.mapAttrsToList (secretName: secret: [
          {
            assertion = isId secret.owner || config.users.users ? ${secret.owner};
            message = "age.secrets.${secretName}.owner is `${secret.owner}`, which is not defined in users.users.";
          }
          {
            assertion = isId secret.group || config.users.groups ? ${secret.group};
            message = "age.secrets.${secretName}.group is `${secret.group}`, which is not defined in users.groups.";
          }
        ])
        enabledSecrets);

    systemd.services = lib.mkMerge [
      (triggers "restartUnits" (_: value: {restartTriggers = value;}))
      (triggers "reloadUnits" reloadTriggers)
    ];
  };
}
