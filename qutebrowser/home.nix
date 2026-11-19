inputs@{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/qutebrowser/".source = ./.;
  };

  home.packages = (with pkgs; [
    qutebrowser
  ]);
}
