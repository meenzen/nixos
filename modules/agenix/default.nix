{
  config,
  inputs,
  lib,
  ...
}: let
  secrets = lib.filterAttrs (_: secret: secret.enable) config.age.secrets;

  isId = value: builtins.match "[0-9]+" value != null;
in {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  # Otherwise agenix fails to chown the secret during activation and the service can't read it.
  config.assertions = lib.concatLists (lib.mapAttrsToList (secretName: secret: [
      {
        assertion = isId secret.owner || config.users.users ? ${secret.owner};
        message = "age.secrets.${secretName}.owner is `${secret.owner}`, which is not defined in users.users.";
      }
      {
        assertion = isId secret.group || config.users.groups ? ${secret.group};
        message = "age.secrets.${secretName}.group is `${secret.group}`, which is not defined in users.groups.";
      }
    ])
    secrets);
}
