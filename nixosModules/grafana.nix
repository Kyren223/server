{ lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    grafana.enable = lib.mkEnableOption "enables grafana";
  };

  config = lib.mkIf config.grafana.enable {
    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts."grafana.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3030/";
      locations."/".extraConfig = "proxy_set_header Host $host;";
    };

    services.grafana = {
      enable = true;
      settings = {
        server.http_port = 3030;
        server.domain = "grafana.kyren.codes";
      };
    };
  };
}
