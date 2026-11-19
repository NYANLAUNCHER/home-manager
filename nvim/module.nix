# Home-manager module: installs neovim + tools and (optionally) links this config
# to ~/.config/nvim.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nyan.nvim;
in
{
  options.nyan.nvim = {
    enable = lib.mkEnableOption "NYANLAUNCHER's neovim setup";

    full = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include the heavy toolchains (Rust, Julia, shader and bash LSPs).";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix {
        withConfig = false;
        inherit (cfg) full;
      };
      defaultText = lib.literalExpression "neovim + tools, reading ~/.config/nvim";
      description = "The neovim bundle to install.";
    };

    linkConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether home-manager should manage ~/.config/nvim. Disable this if you
        link it yourself.
      '';
    };

    configPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/nixos/.local/home-manager/nvim";
      description = ''
        Absolute path to a checkout of this directory. If set, ~/.config/nvim is a
        symlink straight to it (outside the nix store), so edits apply without a
        home-manager switch. If null, a read-only copy in the nix store is used.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."nvim" = lib.mkIf cfg.linkConfig {
      source =
        if cfg.configPath != null then
          config.lib.file.mkOutOfStoreSymlink cfg.configPath
        else
          (pkgs.callPackage ./package.nix { }).configDir;
    };
  };
}
