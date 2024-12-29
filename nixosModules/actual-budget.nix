{ pkgs, lib, config, ... }: {

  options = {
    actual-budget.enable = lib.mkEnableOption "enables actual-budget";
  };

  config = lib.mkIf config.actual-budget.enable {
    # services.nginx.virtualHosts."budget.kyren.codes" = {
    #     useACMEHost = "kyren.codes";
    #     forceSSL = true;
    #
    #     locations."/".proxyPass = "http://actual-server:5006/";
    #     locations."/".extraConfig = ''
    #       include /config/nginx/proxy.conf;
    #       include /config/nginx/resolver.conf;
    #
    #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #       proxy_set_header Host $host;
    #     '';
    #
    # };
  };
}
