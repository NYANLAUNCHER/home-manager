{
  description = "NYANLAUNCHER's yazi config, with yazi and its dependencies.";

  # Try it anywhere:
  #   nix shell 'github:NYANLAUNCHER/home-manager?dir=yazi'
  # Home-manager:
  #   imports = [ inputs.nyan-yazi.homeManagerModules.default ];
  #   nyan.yazi.enable = true;

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { };
      });

      homeManagerModules.default = ./module.nix;
      homeModules.default = ./module.nix;
    };
}
