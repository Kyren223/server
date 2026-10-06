{ lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    gitolite.enable = lib.mkEnableOption "enables gitolite";
  };

  config = lib.mkIf config.gitolite.enable {
    users.groups.git = { };
    users.users.git = {
      isNormalUser = true;
      group = "git";
      home = "/var/lib/gitolite";
      description = "gitolite Service";
    };

    services.gitolite = {
      enable = true;
      user = "git";
      group = "git";
      adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren";
    };
  };
}
