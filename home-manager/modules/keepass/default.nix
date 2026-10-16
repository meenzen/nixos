{
  config,
  lib,
  pkgs,
  ...
}: let
  # Applied to the existing keepassxc.ini on every activation. The file stays writable, because KeePassXC also stores
  # its own state there, like the KeeShare key pair.
  settings = {
    General.BackupBeforeSave = true;
    Browser = {
      Enabled = true;
      # The native messaging manifest is installed by programs.keepassxc
      UpdateBinaryPath = false;
    };
    GUI = {
      MinimizeOnClose = true;
      MinimizeToTray = true;
      ShowTrayIcon = true;
      TrayIconAppearance = "monochrome-light";
    };
    KeeShare.QuietSuccess = true;
    Security.LockDatabaseIdle = false;
  };

  setSettings = lib.concatStrings (lib.mapAttrsToList (section:
    lib.concatMapAttrsStringSep "" (key: value: ''
      run ${lib.getExe pkgs.crudini} --ini-options=nospace --set "$configFile" ${lib.escapeShellArgs [
        section
        key
        (lib.generators.mkValueStringDefault {} value)
      ]}
    ''))
  settings);
in {
  options.meenzen.keepass.enable = lib.mkEnableOption "KeePassXC";

  config = lib.mkIf config.meenzen.keepass.enable {
    programs.keepassxc.enable = true;

    home.activation.keepassxcSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      configFile="${config.xdg.configHome}/keepassxc/keepassxc.ini"
      run mkdir -p "$(dirname "$configFile")"
      ${setSettings}
    '';
  };
}
