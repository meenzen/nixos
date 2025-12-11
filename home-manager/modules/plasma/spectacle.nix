{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.meenzen.plasma.enable {
    programs.plasma.spectacle.shortcuts = {
      captureActiveWindow = "Meta+Print";
      captureCurrentMonitor = "Print";
      captureEntireDesktop = "Shift+Print";
      captureRectangularRegion = "Meta+Shift+S";
      captureWindowUnderCursor = "Meta+Ctrl+Print";
      launch = "Meta+S";
      launchWithoutCapturing = "Meta+Alt+S";
      recordRegion = "Meta+Shift+R";
      recordScreen = "Meta+Alt+R";
      recordWindow = "Meta+Ctrl+R";
    };
  };
}
