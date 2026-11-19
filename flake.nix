{
  description = "NYANLAUNCHER's home-manager config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, home-manager, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.home-manager
      ];
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
              ./home.nix
              ./nvim/home.nix
              ./qutebrowser/home.nix
              ./zsh/home.nix
            ];
          };
        };
    };
}
