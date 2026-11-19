# Neovim + the tools/language servers this config expects.
#
#   withConfig = true   `nvim` launches with the config in this directory, no matter
#                       what is in ~/.config/nvim. Used by `nix shell`/`nix run`.
#   withConfig = false  Plain neovim + tools; neovim reads ~/.config/nvim as usual.
#                       Used by the home-manager module, which links the config itself.
#   full = false        Skip the heavy toolchains (Rust, Julia, shader + bash LSPs).
{
  lib,
  pkgs,
  symlinkJoin,
  writeShellScriptBin,
  withConfig ? true,
  full ? true,
}:
let
  # The config files only; the nix plumbing in this directory isn't part of the config.
  configDir = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.difference ./. (
      lib.fileset.unions (
        map lib.fileset.maybeMissing [
          ./flake.nix
          ./flake.lock
          ./package.nix
          ./module.nix
          ./.gitignore
          ./home.nix # superseded by module.nix
        ]
      )
    );
  };

  tools =
    (with pkgs; [
      xxd
      # Needed by lazy.nvim, nvim-treesitter and telescope-fzf-native to fetch/build plugins
      git
      curl
      gnutar
      gzip
      unzip
      gnumake
      tree-sitter
      ripgrep
      fd
      # Lua
      lua
      lua-language-server
      # C/C++
      gcc
      ccls
      # Nix
      nixd
      nixdoc
    ])
    ++ lib.optionals full (
      with pkgs;
      [
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
      ]
    );

  # Nix store paths are read-only, but lazy.nvim writes its lockfile (and debug.lua its
  # keymap export) into stdpath('config'). So the config is copied to a writable
  # ~/.config/nyan-nvim and nvim is pointed at it with NVIM_APPNAME. This also keeps
  # plugins/state in ~/.local/share/nyan-nvim, separate from any other neovim setup.
  # The copy is refreshed whenever the flake's config changes.
  wrapper = writeShellScriptBin "nvim" ''
    set -eu
    export PATH="${lib.makeBinPath tools}''${PATH:+:$PATH}"

    src=${configDir}
    appname=nyan-nvim
    config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
    dest="$config_home/$appname"
    stamp="$dest/.nix-source"

    if [ "$(cat "$stamp" 2>/dev/null || true)" != "$src" ]; then
      if [ -e "$dest" ] && [ ! -e "$stamp" ]; then
        echo "nvim: $dest exists but wasn't created by this wrapper; refusing to overwrite it." >&2
        exit 1
      fi
      mkdir -p "$config_home"
      tmp=$(mktemp -d "$dest.XXXXXX")
      chmod 755 "$tmp"
      cp -rT --no-preserve=mode,ownership "$src" "$tmp"
      printf '%s\n' "$src" > "$tmp/.nix-source"
      rm -rf "$dest"
      mv "$tmp" "$dest"
    fi

    export NVIM_APPNAME="$appname"
    exec ${pkgs.neovim}/bin/nvim "$@"
  '';
in
symlinkJoin {
  name = "nyanlauncher-neovim${lib.optionalString (!full) "-base"}";
  # symlinkJoin keeps the first file it sees, so the wrapper's `nvim` wins over neovim's.
  paths = lib.optional withConfig wrapper ++ [ pkgs.neovim ] ++ tools;
  passthru = { inherit configDir; };
  meta.mainProgram = "nvim";
}
