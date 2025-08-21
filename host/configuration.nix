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
    ./../nixosModules/grafana.nix
    ./../nixosModules/loki.nix
    ./../nixosModules/stalwart.nix
  ];

  networking.hostName = "kyren-server";

  networking.interfaces.ens3.ipv6.addresses = [
    {
      address = "2a03:4000:15:c6::1";
      prefixLength = 64;
    }
  ];

  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };

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
    fastfetch
    inetutils
    inotify-tools
    net-tools
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
  gitea.enable = false;
  syncthing.enable = true;
  nextcloud.enable = true;
  wakapi.enable = true;
  eko.enable = true;
  stalwart.enable = true;

  # Automatically pull this config from git
  autoUpdate.enable = true;

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
