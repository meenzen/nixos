{
  lib,
  config,
  ...
}: {
  # fix shebangs like '/bin/bash', see https://github.com/Mic92/envfs
  services.envfs = lib.mkIf config.meenzen.desktop.enable {
    enable = true;
  };
}
