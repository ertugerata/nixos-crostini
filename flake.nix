{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixos-generators,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      modules = [
        ./configuration.nix
        ./crostini.nix
      ];

      # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-flake-and-module-system
      specialArgs = { inherit inputs; };

      # https://ayats.org/blog/no-flake-utils
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # NOTE: change to `x86_64-linux` if that is your architecture.
      targetSystem = "aarch64-linux";

    in
    {
      packages = forAllSystems (system: rec {
        lxc = nixos-generators.nixosGenerate {
          inherit system specialArgs modules;
          format = "lxc";
        };
        lxc-metadata = nixos-generators.nixosGenerate {
          inherit system specialArgs modules;
          format = "lxc-metadata";
        };

        lxc-image-and-metadata = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
          name = "lxc-image-and-metadata";
          dontUnpack = true;

          installPhase = ''
            mkdir -p $out
            ln -s ${lxc-metadata}/tarball/*.tar.xz $out/metadata.tar.xz
            ln -s ${lxc}/tarball/*.tar.xz $out/image.tar.xz
          '';
        };

        default = self.packages.${system}.lxc-image-and-metadata;
      });

      checks = forAllSystems (system: {
        inherit (self.outputs.packages.${system}) lxc-image-and-metadata;
      });

      # This allows you to re-build the container from inside the container.
      nixosConfigurations.lxc-nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs modules;
        system = targetSystem;
      };

      nixosModules = rec {
        crostini = ./crostini.nix;
        default = crostini;
      };

      templates.default = {
        path = self;
        description = "nixos-crostini quick start";
      };
    };
}
