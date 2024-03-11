{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    git
    nixFlakes
    nil
    alejandra
  ];
  shellHook = ''
    echo ""
    echo "$(git --version)"
    echo "$(nil --version)"
    echo "$(alejandra --version)"
    echo ""
  '';
}
