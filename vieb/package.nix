# Vieb + this config. Vieb was removed from nixpkgs, so this wraps the upstream AppImage.
#
#   withConfig = true   `vieb` uses the viebrc/.env in this directory.
#                       Used by `nix shell`/`nix run`.
#   withConfig = false  `vieb` uses ~/.config/vieb (or $VIEB_CONFIG_DIR). Used by the
#                       home-manager module, which links the config itself.
#
# Binaries: `vieb` (run.sh: --session/--temp support) and `vieb-mkerwic`.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  makeWrapper,
  coreutils,
  withConfig ? true,
}:
let
  version = "12.11.0";

  sources = {
    x86_64-linux = {
      suffix = "";
      hash = "sha256-yWGPVYDW5s0SnMtxNbNeIZNAOVWL5WvwCMyUD6Rw3hQ=";
    };
    aarch64-linux = {
      suffix = "-arm64";
      hash = "sha256-n5vIo/kH2Xs1affoZgaPeF9pfubT0G2KFMPMHSEpzCg=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "vieb: unsupported system ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/Jelmerro/Vieb/releases/download/${version}/Vieb-${version}${source.suffix}.AppImage";
    inherit (source) hash;
  };

  appimage = appimageTools.wrapType2 {
    pname = "vieb-appimage";
    inherit version src;
  };
  appimageContents = appimageTools.extract {
    pname = "vieb";
    inherit version src;
  };

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
in
stdenvNoCC.mkDerivation {
  pname = "nyanlauncher-vieb";
  inherit version;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/vieb
    cp -r ${configDir}/. $out/share/vieb/
    chmod -R u+w $out/share/vieb

    makeWrapper $out/share/vieb/run.sh $out/bin/vieb \
      --prefix PATH : ${lib.makeBinPath [ coreutils ]} \
      --set VIEB_BIN ${appimage}/bin/vieb-appimage \
      ${
        if withConfig then
          "--set-default VIEB_CONFIG_DIR $out/share/vieb"
        else
          ''--run 'export VIEB_CONFIG_DIR="''${VIEB_CONFIG_DIR:-''${XDG_CONFIG_HOME:-$HOME/.config}/vieb}"' ''
      }
    makeWrapper $out/share/vieb/erwic/mkerwic.sh $out/bin/vieb-mkerwic \
      --prefix PATH : ${lib.makeBinPath [ coreutils ]}

    install -Dm444 ${appimageContents}/vieb.desktop $out/share/applications/vieb.desktop
    substituteInPlace $out/share/applications/vieb.desktop \
      --replace-fail 'Exec=AppRun' "Exec=$out/bin/vieb"
    cp -r ${appimageContents}/usr/share/icons $out/share/icons

    runHook postInstall
  '';

  passthru = { inherit configDir appimage; };

  meta = {
    description = "Vim Inspired Electron Browser, with NYANLAUNCHER's config";
    homepage = "https://vieb.dev";
    license = lib.licenses.gpl3Plus;
    platforms = builtins.attrNames sources;
    mainProgram = "vieb";
  };
}
