# Public host keys, used by agenix-rules.nix and to assert that every host can decrypt its secrets.
# The attribute names must match networking.hostName.
# ssh-keyscan -t ed25519 <host>
{
  neon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdUsfwRNDJCe4DTStnmP6Se+Af8V5+Lqp1iSBSGWBKD";
  framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILK3+4hV7Nt878acFUZkA/+TP1/l3gBQ/k1EHY4V94IF";
  lithium = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLYEzntiA+6Fe8j2wKmwOgXxKA3lqBVf1kz7L4dQPmt";
}
