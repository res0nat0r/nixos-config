{ ... }:

{
  programs.git = {
    enable = true;
    userName = "*Kim Zick (rummik)";
    userEmail = "k@9k1.us";

    signing = {
      key = "D72F9A68A07514C3815A0D31739CF2CBEF8202E5";
    };

    ignores = [
      "*.sw?"
      "*.todo"
      "*.undodir"
      "Session.vim"
    ];
  };
}
