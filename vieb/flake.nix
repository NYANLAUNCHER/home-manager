{
  description = "NYANLAUNCHER's vieb config, with vieb itself.";

  # Try it anywhere:
  #   nix shell 'github:NYANLAUNCHER/home-manager?dir=vieb'
  # Home-manager:
  #   imports = [ inputs.nyan-vieb.homeManagerModules.default ];
  #   nyan.vieb.enable = true;

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
