# Home-manager module: installs yazi + dependencies and links this config to
# ~/.config/yazi.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nyan.yazi;
in
{
  options.nyan.yazi = {
    enable = lib.mkEnableOption "NYANLAUNCHER's yazi setup";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { withConfig = false; };
      defaultText = lib.literalExpression "yazi + dependencies, reading ~/.config/yazi";
      description = "The yazi bundle to install.";
    };

    linkConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether home-manager should manage ~/.config/yazi.";
    };

    configPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/nixos/.local/home-manager/yazi";
      description = ''
        Absolute path to a checkout of this directory. If set, ~/.config/yazi is a
        symlink straight to it (outside the nix store), so edits apply without a
        home-manager switch and `ya pkg` can write package.toml. If null, a
        read-only copy in the nix store is used.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."yazi" = lib.mkIf cfg.linkConfig {
      source =
        if cfg.configPath != null then
          config.lib.file.mkOutOfStoreSymlink cfg.configPath
        else
          (pkgs.callPackage ./package.nix { }).configDir;
    };
  };
}
