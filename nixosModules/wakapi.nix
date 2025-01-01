{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    wakapi.enable = lib.mkEnableOption "enables wakapi";
  };

  config = lib.mkIf config.wakapi.enable {

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts."waka.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3003/";
    };

    systemd.services.wakapi.serviceConfig.StateDirectoryMode = lib.mkForce "0777";
    services.wakapi.enable = true;
    services.wakapi = {
      database.createLocally = false;
      passwordSalt = "dad8uadu8ad8a";
      settings = {
        env = "production";
        port = 3003;
        public_url = "http://waka.kyren.codes:3003";
        db.name = "wakapi_db.db";
        # db.dialect = "postgres";
        db.dialect = "sqlite3";
        db.max_conn = 1;
      };
    };
  };
}
