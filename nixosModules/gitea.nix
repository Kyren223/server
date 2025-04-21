{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    gitea.enable = lib.mkEnableOption "enables gitea";
  };

  config = lib.mkIf config.gitea.enable {
    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts."git.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3001/";
    };

    # Configure database
    services.postgresql.enable = true;
    services.postgresql = {
      ensureDatabases = [ config.services.gitea.user ];
      ensureUsers = [
        {
          name = config.services.gitea.database.user;
          # ensurePermissions."DATABASE ${config.services.gitea.database.name}" = "ALL PRIVILEGES";
        }
      ];
    };

    sops.secrets.gitea-db-password = {
      owner = config.services.gitea.user;
    };

    services.gitea = {
      enable = true;
      appName = "Kyren's Gitea";
      database = {
        type = "postgres";
        passwordFile = config.sops.secrets.gitea-db-password.path;
      };
      settings.server = {
        DOMAIN = "git.kyren.codes";
        ROOT_URL = "https://git.kyren.codes/";
        HTTP_PORT = 3001;
      };
    };
  };
}
