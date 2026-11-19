{
  description = "NYANLAUNCHER's neovim config.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let 
          # The minimum required packages for my neovim config
          base-pkgs = (with pkgs; [
            neovim
            # Shell Utils
            xxd gcc
            # Lua
            lua lua-language-server
            # Nix
            nixd nixdoc
          ]);
          # The packages I use for regular development
          default-pkgs = (with pkgs; [
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
        in {
          packages.base = pkgs.symlinkJoin {
            name = "nyanlauncher-neovim-base";
            paths = base-pkgs;
          };
          packages.default = pkgs.symlinkJoin {
            name = "nyanlauncher-neovim";
            paths = default-pkgs;
          };
          homeManagerModules.default = { pkgs, ... }: {
            programs.neovim = {
              enable = true;
              package = self'.packages.${pkgs.system}.default;
            };
          };
        };
      flake = { };
    };
}
