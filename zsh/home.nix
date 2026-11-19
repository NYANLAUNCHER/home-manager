inputs@{ config, pkgs, lib, ... }:
{
  home.file = {
    ".zshenv".source = lib.mkForce ./.zshenv;
    ".zshrc".source = lib.mkForce ./.zshrc;
    ".config/zsh/".source = lib.mkForce ./.;
  };

  home.packages = (with pkgs; [
    neovim
    # Shell Utils
    xxd gcc
    # Lua
    lua lua-language-server
    # Nix
    nixd nixdoc
    # C/C++
    clang clang-tools
    # Rust
    rustc
    cargo
    rust-analyzer
    taplo
    # Personal-Knowledge-Management
    markdown-oxide
    # Shell Script
    bash-language-server
  ]);
}
