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
    systemd.services.wakapi.serviceConfig = {
      StateDirectoryMode = lib.mkForce "0777";
      DynamicUser = true;
      ProtectHome = lib.mkForce false;
      ProtectHostname = lib.mkForce false;
      ProtectKernelLogs = lib.mkForce false;
      ProtectKernelModules = lib.mkForce false;
      ProtectKernelTunables = lib.mkForce false;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = lib.mkForce false;
      RestrictRealtime = lib.mkForce false;
      RestrictSUIDSGID = lib.mkForce false;
    };

    services.postgresql.enable = true;
    services.postgresql.ensureDatabases = [ "wakapi" ];
    services.postgresql.ensureUsers."wakapi".ensureDBOwnership = true;

    services.wakapi.enable = true;
    services.wakapi = {
      database.createLocally = true;
      database.name = "wakapi_db.db";
      database.user = "wakapi";
      passwordSalt = "dad8uadu8ad8a";
      settings = {
        env = "production";
        port = 3003;
        public_url = "https://waka.kyren.codes";
        db.name = "wakapi_db.db";
        db.dialect = "postgres";
        db.user = "wakapi";
        db.password = "1234";
        db.host = "127.0.0.1";
        db.port = 5432;
      };
    };
  };
}
