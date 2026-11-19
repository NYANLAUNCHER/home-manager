{
  description = "My (NYANLAUNCHER's) *deterministic* neovim config.";

  # Try it anywhere:
  #   nix shell 'github:NYANLAUNCHER/home-manager?dir=nvim'        (full)
  #   nix shell 'github:NYANLAUNCHER/home-manager?dir=nvim#base'   (minimal)
  # Home-manager:
  #   imports = [ inputs.nyan-nvim.homeManagerModules.default ];
  #   nyan.nvim.enable = true;

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
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./package.nix { };
          # For a more minimal/quick setup
          base = pkgs.callPackage ./package.nix { full = false; };
        }
      );

      homeManagerModules.default = ./module.nix;
      homeModules.default = ./module.nix;
    };
}
