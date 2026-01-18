inputs@{ config, pkgs, lib, ... }:
{
  home.packages = (with pkgs; [
    neovim
    nil # Nix LSP
    bash-language-server
    # Lua
    lua lua-language-server
    # Rust
    rustc
    cargo
    rust-analyzer
    taplo
    # C/C++
    gcc ccls
    # GLSL
    glsl_analyzer
  ]);
}
