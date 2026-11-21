{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/nvim/".source = ./.;
  };

  home.packages = (with pkgs; [
    neovim
    # Shell Utils
    xxd tree-sitter
    # Lua
    lua lua-language-server
    # Nix
    nixd nixdoc
    # C/C++
    clang clang-tools # clangd
    # Rust
    rustc
    cargo
    rust-analyzer
    taplo
    # Personal-Knowledge-Management
    markdown-oxide
    quarto
    # Shell Scripting
    bash-language-server
    checkbashisms
  ]);
}
