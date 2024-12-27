{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."185.170.113.195" = {
      extraConfig = ''
        error_page 404 /404.html;
        location = /404.html {
                root /srv/website;
                internal;
        }
      '';
      listen = [{
        addr = "0.0.0.0";
        port = 80;
      }];
      locations."/" = {
        index = "index.html";
        root = "/srv/website";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
