inputs@{ config, pkgs, lib, ... }:
{
  home.file = {
    ".zshenv".source = lib.mkForce ./.zshenv;
    ".zshrc".source = lib.mkForce ./.zshrc;
    ".config/zsh/".source = lib.mkForce ./.;
  };
  home.packages = (with pkgs; [
    zsh
  ]);
}
