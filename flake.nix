{
  description = "NYANLAUNCHER's home-manager config.";

  # Enable Git submodules
  inputs.self.submodules = true;
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vis = {
      url = "path:./vis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.home-manager.flakeModules.home-manager ];
      flake = # See: https://nix-community.github.io/home-manager/nix-flakes/flake-parts.html
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; };
          mkHome = username: homeDirectory:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              # Pass arguments to modules
              extraSpecialArgs = {inherit username homeDirectory inputs;};
              modules = [
                ./home.nix
                ./luakit/home.nix
                ./nvim/home.nix
                ./zsh/home.nix
              ];
            };
        in {
          homeConfigurations = {
            #         mkHome <username> <homeDirectory>
            markiep = mkHome "markiep"  "/home/markiep";
            nixos   = mkHome "nixos"    "/home/nixos";
          };
        };
    };
}
