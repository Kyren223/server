{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."185.170.113.195" = {
      listen = [{
        addr = "0.0.0.0";
        port = 80;
      }];
      locations."/" = {
        index = "index.html";
        root = /srv/website
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
