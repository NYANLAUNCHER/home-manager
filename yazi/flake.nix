{
  description = "Install Yazi and Dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # You can choose stable or unstable branches
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    my-yazi-cfg = stdenv.mkDerivation {
      name = "my-yazi-cfg";
      version = pkgs.yazi.version;
      installPhase = ''
         mkdir -p $out/bin
         makeWrapper ${pkgs.yazi}/bin/nvim $out/bin/nvim \
         --prefix PATH : ${vimUtils.vimPath} \
         --set VIMRUNTIME ${vimUtils.vimRuntimePath} \
         --set XDG_CONFIG_DIRS "$out/etc/xdg" \
         --set XDG_DATA_DIRS "$out/share"
       '';
    };
  in {
    packages.default = pkgs.symlinkJoin {
      name = "yazi";
      buildInputs = [ pkgs.makeWrapper ];
      paths = with pkgs; [
        yazi
        poppler
        unar
        fzf
        fd
        ripgrep-all
        ffmpegthumbnailer
        jq
      ] ++ my-yazi-cfg;
      postBuild = ''
        mkdir -p $out/share/yazi
        cp ./* $out/share/yazi
        wrapProgram $out/bin/yazi \
          --set YAZI_CONFIG_HOME "$out/share/yazi"
      '';
    };
  });
}
