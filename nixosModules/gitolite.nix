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
      isSystemUser = true;
      group = "git";
      home = "/var/lib/gitolite";
    };

    services.gitolite = {
      enable = true;
      user = "git";
      group = "git";
      adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren";
    };

    programs.git.config = {
      init.defaultBranch = "master"
    };
  
  };
}
