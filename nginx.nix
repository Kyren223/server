{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."kyren.codes" = {
      listen = [{
        addr = "0.0.0.0";
        port = 80;
      }];

      locations."/" = {
        index = "index.html";
        root = "/srv/website";
      };

      locations."/404.html" = {
        root = "/srv/website";
      };
      extraConfig = ''
        error_page 404 /404.html;
      '';

    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
