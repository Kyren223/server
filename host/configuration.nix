{ modulesPath, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./../nixosModules/secrets.nix
    ./../nixosModules/website.nix
    ./../nixosModules/auto-updade.nix
    ./../nixosModules/actual-budget.nix
    ./../nixosModules/gitea.nix
    ./../nixosModules/syncthing.nix
    ./../nixosModules/nextcloud.nix
    ./../nixosModules/wakapi.nix
    ./../nixosModules/eko.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Admin utilities
  environment.systemPackages = with pkgs; map lib.lowPrio [
    curl
    gitMinimal
    neovim
    openssl
    sqlite
    btop
    vim
  ];

  # Enable dynamic linking
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  users.users.root.hashedPassword = "$y$j9T$ZT9dUDb5fMGtQTQumYE49.$KI98XnTuykSgTAeP/gttTzEaj0Ys834WxAtKzT1CAb6";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
  ];

  secrets.enable = true;

  # Apps
  website.enable = true;
  actualBudget.enable = true;
  gitea.enable = true;
  syncthing.enable = true;
  nextcloud.enable = false;
  wakapi.enable = true;
  eko.enable = true;

  # Automatically pull this config from git
  autoUpdate.enable = true;

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
