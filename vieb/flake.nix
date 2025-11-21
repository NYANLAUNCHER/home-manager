{
  description = "Portable Vieb flake with a clean, wrapper-less devShell.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
  flake-utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs { inherit system; };
      viebRuntimeDeps = with pkgs; [
        vieb
        mpv
      ];

      viebConfigPath = "/share/vieb";# relative to path in /nix/store/

      # This wrapper relies on Nix's env mechanism for XDG_CONFIG_HOME and PATH inheritance.
      simpleViebWrapper = pkgs.writeScriptBin "vieb" "exec ${pkgs.vieb}/bin/vieb \"\$@\"";

      myVieb = pkgs.stdenv.mkDerivation {
        pname = "vieb-flake";
        version = "1.0.0";
        src = pkgs.lib.cleanSource ./.;
        buildInputs = [ simpleViebWrapper ];

        env = {
          # Directs Neovim to look for config in the immutable store path.
          XDG_CONFIG_HOME = "$out/share";
          # Sets data directory outside of the Nix store for cache and plugins.
          XDG_DATA_HOME = "$HOME/.local/share/vieb-global-data";
          PATH = pkgs.lib.makeBinPath viebRuntimeDeps;
        };

        installPhase = ''
          mkdir -p $out/bin $out${viebConfigPath}
          # Copy the vieb config directory from the source subdirectory
          cp -r $src/* $out${viebConfigPath}/
          cp ${simpleViebWrapper}/bin/vieb $out/bin/
        '';
      };
    in
    {
      packages.default = myVieb;
      apps.vieb = {
        type = "app";
        program = "${myVieb}/bin/vieb";
      };

      devShells.default = pkgs.mkShell {
        packages = viebRuntimeDeps;

        shellHook = ''
          NIX_CONFIG_PATH="${myVieb}/share"
          export source=$src

          # This function runs every time 'vieb' is called in the shell.
          vieb() {
            if [ -d "./vieb" ]; then
              echo "Using project-local Neovim config: ./vieb" >&2
              # Using built-in $PWD for the current directory
              XDG_CONFIG_HOME="$PWD" XDG_DATA_HOME="$HOME/.local/share/vieb-project-data" ${pkgs.neovim}/bin/vieb "$@"
            else
              echo "Using flake's immutable config: $NIX_CONFIG_PATH/vieb" >&2
              # Use the immutable flake config
              XDG_CONFIG_HOME="$NIX_CONFIG_PATH" XDG_DATA_HOME="$HOME/.local/share/vieb-project-data" ${pkgs.neovim}/bin/vieb "$@"
            fi
          }
        '';
      };
    }
  );
}
