{ pkgs, lib, config, ... }: {

  options = {
    wallabag.enable = lib.mkEnableOption "enables wallabag";
  };

  config = lib.mkIf config.wallabag.enable {
    users.groups.wallabag = { };
    users.users.wallabag = {
      createHome = false;
      isNormalUser = true;
      group = "wallabag";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
      ];
    };

  };
}
