{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    syncthing.enable = lib.mkEnableOption "enables syncthing";
  };

  config = lib.mkIf config.syncthing.enable {
    # 443 and 80 for for http and https
    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    networking.firewall.allowedTCPPorts = [ 22000 443 80 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts."sync.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8384/";
    };

    users.users.syncthing = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
      ];
    };

    # Make sure the dir is created with the correct perms
    # Can't use users to do it due to being a system user
    systemd.tmpfiles.rules = [
      "d /home/syncthing 0700 syncthing users"
    ];

    services.syncthing = {
      enable = true;
      group = "syncthing";
      user = "syncthing";
      dataDir = "/home/syncthing/data";
      configDir = "/home/syncthing/config";
      overrideDevices = true;
      settings.devices = {
        "kyren-laptop" = { id = "XV2ODEO-KBUQSZD-ZNAJD3N-FV4M64X-RQG4NLD-FUIMUL3-OWGNMS4-S5XTDAO"; };
      };
    };
  };
}
