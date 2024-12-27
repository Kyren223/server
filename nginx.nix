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

  security.acme = {
    acceptTerms = true;
    defaults.email = "kyren223@proton.me";
    certs."kyren.codes" = {
      extraDomainNames = [ "*.kyren.codes" ];
      dnsProvider = "namecheap";
      environmentFile = "${pkgs.writeText "namecheap-creds" ''
        NAMECHEAP_API_USER=${builtins.readFile "/run/secrets/namecheap-api-user"}
        NAMECHEAP_API_KEY=${builtins.readFile "/root/namecheap-api-key"}
      ''}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
