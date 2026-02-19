{
  description = "My (NYANLAUNCHER's) *deterministic* neovim config.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let 
        # The base-level packages I might need in a minimal environment
        base-pkgs = (with pkgs; [
          neovim
          xxd
          # Lua
          lua lua-language-server
          # C/C++
          gcc ccls
          # Nix
          nixd nixdoc
        ]);
      in {
        # For a more minimal/quick setup
        packages.base = pkgs.symlinkJoin {
          name = "nyanlauncher-neovim-base";
          paths = base-pkgs;
        };

        packages.default = pkgs.symlinkJoin {
          name = "nyanlauncher-neovim";
          paths = base-pkgs ++ (with pkgs; [
            # Julia
            julia-bin
            # Rust
            rustc
            cargo
            rust-analyzer
            taplo
            # Shaders
            glsl_analyzer
            wgsl-analyzer
            # Shell Script
            bash-language-server
          ]);
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
