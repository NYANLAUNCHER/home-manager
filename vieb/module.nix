# Home-manager module: installs vieb and links this config to ~/.config/vieb.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nyan.vieb;
in
{
  options.nyan.vieb = {
    enable = lib.mkEnableOption "NYANLAUNCHER's vieb setup";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { withConfig = false; };
      defaultText = lib.literalExpression "vieb, reading ~/.config/vieb";
      description = "The vieb package to install.";
    };

    linkConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether home-manager should manage ~/.config/vieb.";
    };

    configPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/nixos/.local/home-manager/vieb";
      description = ''
        Absolute path to a checkout of this directory. If set, ~/.config/vieb is a
        symlink straight to it (outside the nix store), so edits apply without a
        home-manager switch. If null, a read-only copy in the nix store is used.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."vieb" = lib.mkIf cfg.linkConfig {
      source =
        if cfg.configPath != null then
          config.lib.file.mkOutOfStoreSymlink cfg.configPath
        else
          (pkgs.callPackage ./package.nix { }).configDir;
    };
  };
}
