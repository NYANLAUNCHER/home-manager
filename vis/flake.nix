{
  description = "Vis: A vi-like editor based on Plan 9's structural regular expressions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nativeBuildInputs = with pkgs; [ # build-time dependencies
        ];
        buildInputs = with pkgs; [ # runtime dependencies
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
        ];
      in {
        packages.default = pkgs.buildEnv {
          name = "nyanlauncher-vis";
          pathsToLink = [ "/bin" "/share" ];
          extraOutputsToInstall = [ "man" "doc" ];
          paths = buildInputs;
        };
        devShells.default = pkgs.mkShell { inherit nativeBuildInputs buildInputs; };
      });
}
