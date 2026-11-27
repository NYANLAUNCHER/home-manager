{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/vis/" = {
      source = ./.;
      recursive = true;
      force = true;
    };
  };

  home.packages = (with pkgs; [
    vis
    # Shell Utils
    xxd tree-sitter
    # Lua
    lua lua-language-server luarocks
    # Nix
    nixd nixdoc
    # Shell Scripting
    bash-language-server
    checkbashisms
  ]);
}
