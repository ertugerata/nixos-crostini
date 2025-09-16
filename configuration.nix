# Originally taken from:
# https://github.com/Misterio77/nix-starter-configs/blob/cd2634edb7742a5b4bbf6520a2403c22be7013c6/minimal/nixos/configuration.nix
# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # You can import other NixOS modules here.
    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
  ];

  networking.hostName = "penguin-nixos";

  # Enable flakes: https://nixos.wiki/wiki/Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Search for additional packages here: https://search.nixos.org/packages
  environment.systemPackages = [ pkgs.neovim
  				 pkgs.git];

  # Enable docker
  virtualisation.docker.enable = true;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # TODO: Replace `aldur` with your username
    ertugrulerata = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here if you plan on using SSH to connect
      ];
      extraGroups = [ "wheel" "docker" ];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
