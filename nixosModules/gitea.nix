{ lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    gitea.enable = lib.mkEnableOption "enables gitea";
  };

  config = lib.mkIf config.gitea.enable {
    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts."git.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3001/";
    };

    # Configure database
    services.postgresql.enable = true;
    services.postgresql = {
      ensureDatabases = [ "gitea" ];
      ensureUsers = [
        # {
        #   name = "git";
        #   # ensureDBOwnership = true;
        #   # ensurePermissions."DATABASE ${config.services.gitea.database.name}" = "ALL PRIVILEGES";
        # }
        {
          name = "gitea";
        }
      ];
    };

    sops.secrets.gitea-db-password = { owner = config.services.gitea.user; };

    users.groups.git = { };
    users.users.git = {
      isSystemUser = true;
      group = "git";
      home = "/var/lib/gitea";
      description = "Gitea Service";
    };

    services.gitea = {
      enable = true;
      appName = "Kyren's Code";
      user = "git";
      group = "git";
      database = {
        # user = "gitea";
        # name = "gitea";
        type = "postgres";
        passwordFile = config.sops.secrets.gitea-db-password.path;
        createDatabase = false;
      };
      settings.server = {
        DOMAIN = "git.kyren.codes";
        ROOT_URL = "https://git.kyren.codes/";
        HTTP_PORT = 3001;
      };
      mailerPasswordFile = config.sops.secrets.stalwart-git-password.path;
      extraConfig = builtins.readFile ./gitea.ini;
    };
  };
}
