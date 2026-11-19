{
  description = "NYANLAUNCHER's neovim config.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, ... }: {
      flake =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          # Minimum required packages
          base-pkgs = with pkgs; [
            neovim
            # Shell Utils
            xxd gcc tree-sitter
            # Lua
            lua lua-language-server
            # Nix
            nixd nixdoc
          ];

          # Regular development packages
          default-pkgs = base-pkgs ++ (with pkgs; [
            # C/C++
            clang clang-tools
            # Rust
            rustc cargo rust-analyzer taplo
            # Personal Knowledge Management
            markdown-oxide
            # Shell Script
            bash-language-server checkbashisms
          ]);
        in {
          homeModules.neovim = { pkgs, ... }: {
            home.packages = default-pkgs;
            home.sessionVariables.EDITOR = "nvim";
            xdg.configFile."nvim".source = ./.;
          };
        };

    });
}
