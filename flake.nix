{
  description = "NYANLAUNCHER's home-manager config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #nvim = {
    #  url = "path:./nvim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ nixpkgs, flake-parts, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.home-manager.flakeModules.home-manager ];
      flake = # See: https://nix-community.github.io/home-manager/nix-flakes/flake-parts.html
        let
          username = "nixos";
          homeDirectory = "/home/${username}";
        in {
          # Home-Manager Config
          homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs { system = "x86_64-linux"; };
            # Pass arguments to modules
            extraSpecialArgs = {inherit username homeDirectory;};
            modules = [
              #inputs.nvim.homeModules.neovim
              ./nvim/home.nix
              ./home.nix
              ./zsh/home.nix
            ];
          };
        };
    };
}
