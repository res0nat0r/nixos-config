{ cfg, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs-8_x
    (yarn.override { nodejs = nodejs-8_x; })
  ];

  environment.interactiveShellInit = ''
    export PATH=$HOME/.yarn/bin:$PATH
  '';
}
