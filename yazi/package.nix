# Yazi + its preview/plugin dependencies.
#
#   withConfig = true   `yazi` uses the config in this directory (YAZI_CONFIG_HOME).
#                       Used by `nix shell`/`nix run`.
#   withConfig = false  `yazi` reads ~/.config/yazi as usual. Used by the
#                       home-manager module, which links the config itself.
{
  lib,
  pkgs,
  symlinkJoin,
  makeWrapper,
  withConfig ? true,
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
        ]
      )
    );
  };

  # nixpkgs' yazi already puts jq, poppler, 7zip, ffmpeg, fd, ripgrep, fzf, zoxide,
  # imagemagick, chafa and resvg on its PATH; these are the extras this config uses.
  yazi = pkgs.yazi.override {
    extraPackages = with pkgs; [
      git # git.yazi plugin
      unar
      ffmpegthumbnailer
      ripgrep-all
    ];
  };
in
symlinkJoin {
  name = "nyanlauncher-yazi-${yazi.version}";
  paths = [ yazi ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = lib.optionalString withConfig ''
    wrapProgram $out/bin/yazi --set YAZI_CONFIG_HOME ${configDir}
  '';
  passthru = { inherit configDir; };
  meta.mainProgram = "yazi";
}
