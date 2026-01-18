# `nixos-crostini`: NixOS containers in ChromeOS

This repository provides a sample Nix configuration to build NixOS containers
for Crostini (Linux on ChromeOS). The `crostini.nix` module adds support for:

- clipboard sharing with the container,
- handling of URIs, URLs, etc,
- file sharing,
- and X/Wayland support, so that the container can run GUI applications.

See [this blog post](https://aldur.blog/articles/2025/06/19/nixos-in-crostini)
for more details.

## Quick start

1. [Install Nix](https://github.com/DeterminateSystems/nix-installer).
1. Run `nix flake init -t github:aldur/nixos-crostini` from a new directory (or
   simply clone this repository).
1. Edit the [`./configuration.nix`](./configuration.nix) with your username;
   later on, pick the same when configuring Linux on ChromeOS.

Then:

```shell
# Build the container image and its metadata:
$ nix build
$ ls result
image.tar.xz  metadata.tar.xz
```

That's it! See [this other blog
post](https://aldur.blog/micros/2025/07/19/more-ways-to-bootstrap-nixos-containers/)
for a few ways on how to deploy the image on the Chromebook.

## NixOS module

You can also integrate the `crostini.nix` module in your Nix configuration. If
you are using flakes:

1. Add this flake as an input.
1. Add `inputs.nixos-crostini.nixosModules.nixos-crostini` to your modules.

Here is a _very minimal_ example:

```nix
{
  # Here is the input.
  inputs.nixos-crostini.url = "github:aldur/nixos-crostini";

  # Optional:
  inputs.nixos-crostini.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nixos-crostini }: {
    # Change to your hostname.
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix

        # Here is where it gets added to the modules.
        nixos-crostini.nixosModules.default
      ];
    };

    # Change <system> to  "x86_64-linux", "aarch64-linux"
    # This will allow you to build the image.
    packages."<system>".lxc-image-and-metadata = nixos-crostini.packages."<system>".default;
  };
}
```

## Modifications & Build Artifacts

This fork includes several specific modifications and improvements:

1.  **User Configuration**: The default user is pre-configured as `ertugrulerata` in `configuration.nix`.
2.  **CI/CD Pipeline**: A GitHub Actions workflow (`.github/workflows/ci.yml`) is included to automatically build the LXC image and metadata.
    *   **Artifacts**: Every build produces `image.tar.xz` and `metadata.tar.xz`, which can be downloaded from the "Actions" tab in GitHub.
3.  **Flake Fixes**: The `crostini.nix` module is explicitly included in the flake outputs to ensure critical files (like `/etc/gshadow` via `common.nix`) are generated correctly during the LXC build.
4.  **Baguette Exclusion**: Specific "Baguette" related features have been excluded to keep the image minimal and focused on standard Crostini usage.

### Downloading the Build

You do not need to build locally if you use the CI artifacts:
1. Go to the **Actions** tab of this repository.
2. Click on the latest successful workflow run.
3. Scroll down to **Artifacts** and download `nixos-crostini-x86_64-linux`.
4. Extract the zip file to get `image.tar.xz` and `metadata.tar.xz`.
