{ lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    grafana.enable = lib.mkEnableOption "enables grafana";
  };

  config = lib.mkIf config.grafana.enable {
    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts."grafana.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3030/";
    };

    sops.secrets.gitea-db-password = {
      owner = config.services.gitea.user;
    };

    services.grafana = {
      enable = true;
      settings = {
        server.http_port = 3030;
        server.domain = "kyren.codes";
        security.csrf_additional_headers = [ "grafana.kyren.codes" "<grafana.kyren.codes>" "kyren.codes" "<kyren.codes>" ];
      };
    };
  };
}
