inputs@{ config, pkgs, lib, ... }:
{
  home.packages = (with pkgs; [
    neovim
    nil
    lua
    lua-language-server
    bash-language-server
    rustc
    cargo
    rust-analyzer
    gcc ccls
    glsl_analyzer
  ]);
}
