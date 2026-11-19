{
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # nvim/, yazi/ and vieb/ are also standalone flakes (see their flake.nix). Here they're
  # used straight from this checkout (not as flake inputs), so edits to them apply on the
  # next switch without having to `nix flake update` anything.
  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "nixos";
      homeDirectory = "/home/${username}";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit username homeDirectory;};
        modules = [
          ./nvim/module.nix
          ./yazi/module.nix
          ./vieb/module.nix
          ./home.nix
        ];
      };

      # e.g. `nix shell .#nvim` or `nix run github:NYANLAUNCHER/home-manager#yazi`
      packages.${system} = {
        nvim = pkgs.callPackage ./nvim/package.nix { };
        nvim-base = pkgs.callPackage ./nvim/package.nix { full = false; };
        yazi = pkgs.callPackage ./yazi/package.nix { };
        vieb = pkgs.callPackage ./vieb/package.nix { };
      };
    };
}
