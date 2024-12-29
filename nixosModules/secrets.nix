{ pkgs, lib, config, ... }: {

  options = {
    secrets.enable = lib.mkEnableOption "enables secrets";
  };

  config = lib.mkIf config.secrets.enable {
    sops = {
      defaultSopsFile = ./secrets.yaml;
      age.sshKeyPaths = [ "/root/id_ed25519" ];
    };
  };
}
