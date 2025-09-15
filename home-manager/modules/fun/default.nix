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
    (
      pkgs.writeShellApplication {
        name = "ai";
        text = ''
          echo "AI is now enabled!"
        '';
      }
    )
    (
      pkgs.writeShellApplication {
        name = "llm";
        text = ''
          echo "Generating message..."
          sleep 1
          fortune | ponysay
        '';
      }
    )
  ];
}
