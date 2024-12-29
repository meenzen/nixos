let
  # meenzens-age-secrets
  meenzens = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQE/bN7jUMxVZx91oV4aSbdKQToDfUmIDYCY/NNNkFh";
  users = [meenzens];

  # ssh-keyscan -t ed25519 <host>
  neon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsdZx97CPaUCYagHxZKuB9r9nfRjB2Rv4UWJtWyy+7e";
  systems = [neon];
  mastodon = [neon];
  matrix = [neon];
  authentik = [neon];
  restic = [neon];
  gitlab = [neon];
  collabora = [neon];
  cheshbot = [neon];
  attic = [neon];
in {
  # Mastodon
  "mastodonEmailPassword.age".publicKeys = users ++ mastodon;
  "mastodonActiveRecordPrimaryKey.age".publicKeys = users ++ mastodon;
  "mastodonActiveRecordDeterministicKey.age".publicKeys = users ++ mastodon;
  "mastodonActiveRecordSalt.age".publicKeys = users ++ mastodon;
  "mastodonSecretKeyBase.age".publicKeys = users ++ mastodon;
  "mastodonOtpSecret.age".publicKeys = users ++ mastodon;
  "mastodonVapidPublicKey.age".publicKeys = users ++ mastodon;
  "mastodonVapidPrivateKey.age".publicKeys = users ++ mastodon;
  "mastodonS3Config.age".publicKeys = users ++ mastodon;
  "fedifetcherConfigJson.age".publicKeys = users ++ mastodon;

  # Matrix
  "matrixSharedSecret.age".publicKeys = users ++ matrix;

  # Authentik
  "authentikEnvironment.age".publicKeys = users ++ authentik;

  # Restic
  "resticEnv.age".publicKeys = users ++ restic;
  "resticRepository.age".publicKeys = users ++ restic;
  "resticPassword.age".publicKeys = users ++ restic;

  # GitLab
  "gitlabSecret.age".publicKeys = users ++ gitlab;
  "gitlabOtpSecret.age".publicKeys = users ++ gitlab;
  "gitlabDbSecret.age".publicKeys = users ++ gitlab;
  "gitlabJwsSecret.age".publicKeys = users ++ gitlab;
  "gitlabRootPassword.age".publicKeys = users ++ gitlab;
  "gitlabDatabasePassword.age".publicKeys = users ++ gitlab;

  # Collabora
  "collaboraEnvironment.age".publicKeys = users ++ collabora;

  # CheshBot
  "cheshbotEnvironment.age".publicKeys = users ++ cheshbot;
  "cheshbotPostgresPassword.age".publicKeys = users ++ cheshbot;

  # GitHub Registry
  "githubRegistryPassword.age".publicKeys = users ++ systems;

  # Attic
  "atticEnvironment.age".publicKeys = users ++ attic;
}
