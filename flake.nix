{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixos-generators, nixpkgs, self, ... }@inputs:
    let
      modules = [ ./configuration.nix self.nixosModules.default ];

      # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-flake-and-module-system
      specialArgs = { inherit inputs; };

      # https://ayats.org/blog/no-flake-utils
      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: function system);

    in {
      packages = forAllSystems (system: rec {
        lxc = nixos-generators.nixosGenerate {
          inherit system specialArgs modules;
          format = "lxc";
        };
        lxc-metadata = nixos-generators.nixosGenerate {
          inherit system specialArgs modules;
          format = "lxc-metadata";
        };

        default = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
          name = "lxc-image-and-metadata";
          dontUnpack = true;

          installPhase = ''
            mkdir -p $out
            ln -s ${lxc-metadata}/tarball/*.tar.xz $out/metadata.tar.xz
            ln -s ${lxc}/tarball/*.tar.xz $out/image.tar.xz
          '';
        };
      });

      # This allows you to re-build the container from inside the container.
      nixosConfigurations.lxc-nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs modules;

        # NOTE: change to `x86_64-linux` if that is your architecture.
        system = "aarch64-linux";
      };

      nixosModules = rec {
        nixos-crostini = ./crostini.nix;
        default = nixos-crostini;
      };

      templates.default = {
        path = self;
        description = "nixos-crostini quick start";
      };
    };
}
