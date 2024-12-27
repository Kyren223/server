{ modulesPath, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./nginx.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = with pkgs; map lib.lowPrio [
    curl
    gitMinimal
    neovim
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  users.users.root.hashedPassword = "$y$j9T$ZT9dUDb5fMGtQTQumYE49.$KI98XnTuykSgTAeP/gttTzEaj0Ys834WxAtKzT1CAb6";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
  ];

  users.groups.website = {};
  users.users.website = {
    home = "/srv/website";
    createHome = true;
    isSystemUser = true;
    group = "website";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
    ];
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/var/lib/id_ed25519" ];
    secrets.github-access-token = { };
  };
  nix.extraOptions = "!include /run/secrets/github-access-token";

  system.autoUpgrade = {
    enable = true;
    flake = "github:kyren223/server#default";
    dates = "10s"; # Poll interval
    flags = [ "--option" "tarball-ttl" "0" ]; # Required for polling below 1h
  };

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
