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
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.base = pkgs.symlinkJoin {
          name = "nyanlauncher-neovim-base";
          paths = base-pkgs;
        };

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
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
      };
      flake = { };
    };
}
