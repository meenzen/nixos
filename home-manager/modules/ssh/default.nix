{
  config,
  lib,
  osConfig,
  ...
}: {
  options.meenzen.ssh.enable = lib.mkEnableOption "SSH client configuration";

  config = lib.mkIf config.meenzen.ssh.enable {
    # Desktops use the NixOS agent, which supports askpass prompts
    services.ssh-agent.enable = !osConfig.programs.ssh.startAgent;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      # SSH hosts config
      settings = {
        "*" = {
          addKeysToAgent = "yes";
          compression = false;
          connectTimeout = 15;
          controlMaster = "auto";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "60m";
          hashKnownHosts = true;
          userKnownHostsFile = "~/.ssh/known_hosts";
        };

        "lithium.localdomain" = {
          hostname = "192.168.1.4";
        };

        "mail.meenzen.net" = {
          hostname = "mail.meenzen.net";
          user = "root";
        };
      };
    };
  };
}
