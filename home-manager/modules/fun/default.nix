{pkgs, ...}: {
  home.packages = [
    pkgs.cowsay
    pkgs.ponysay
    pkgs.fastfetch
    pkgs.asciiquarium
    pkgs.clolcat
    pkgs.cmatrix
    pkgs.fortune
    pkgs.sl
    pkgs.bb

    (pkgs.writeScriptBin "ai" ''
      echo "AI is now enabled!"
    '')
    (pkgs.writeScriptBin "llm" ''
      echo "Generating message..."
      sleep 1
      fortune | ponysay
    '')
  ];

  programs.thefuck.enable = true;
}
