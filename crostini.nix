{ modulesPath, lib, ... }:
{
  imports = [
    # Load defaults for running in an lxc container.
    # This is explained in: https://github.com/nix-community/nixos-generators/issues/79
    "${modulesPath}/virtualisation/lxc-container.nix"

    ./common.nix
  ];

  # `boot.isContainer` implies NIX_REMOTE = "daemon"
  # (with the comment "Use the host's nix-daemon")
  # However, in a crostini container, we want to run the nix-daemon inside the
  # container.
  # This is the default value for `boot.isContainer`
  environment.variables.NIX_REMOTE = "daemon";

  networking.hostName = lib.mkDefault "lxc-nixos";
}
