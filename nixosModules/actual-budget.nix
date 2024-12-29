{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    actualBudget.enable = lib.mkEnableOption "enables actual-budget";
  };

  config = lib.mkIf config.actualBudget.enable {

    services.actual.enable = true;
    services.actual.settings.port = 5006;

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts."budget.kyren.codes" = {
        useACMEHost = "budget.kyren.codes";
        forceSSL = true;

        locations."/".proxyPass = "http://localhost:5006/";
        locations."/".extraConfig = ''
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $host;
        '';

    };
  };
}
