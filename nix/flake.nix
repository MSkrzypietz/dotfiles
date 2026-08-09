{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    pi.url = "github:lukasl-dev/pi.nix";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, stylix, ... }@inputs:
    let
      system = "x86_64-linux";

      # Local packages, shared between the flake output and the NixOS config.
      plannotatorOverlay = final: prev: {
        plannotator = final.callPackage ./pkgs/plannotator { };
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ plannotatorOverlay ];
      };
    in
    {
      packages.${system}.plannotator = pkgs.plannotator;

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [ plannotatorOverlay ];
            }
            stylix.nixosModules.stylix
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.michael = ./home.nix;
            }
          ];
        };
      };
    };
}
