{ pkgs, lib, config, ... }: {

  options = {
    syncthing.enable = lib.mkEnableOption "enables syncthing";
  };

  config = lib.mkIf config.syncthing.enable {

    # 22000 TCP and/or UDP for sync traffic
    # 21027/UDP for discovery
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    servicessyncthing = {
      enable = true;
      group = "syncthing";
      user = "syncthing";
      dataDir = "/home/syncthing/data";
      configDir = "/home/syncthing/config";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "kyren-laptop" = { id = "XV2ODEO-KBUQSZD-ZNAJD3N-FV4M64X-RQG4NLD-FUIMUL3-OWGNMS4-S5XTDAO"; };
        };
        folders = { };
      };
    };
  };
}
