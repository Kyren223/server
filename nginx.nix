{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."kyren.codes" = {
      # forceSSL = true;
      # enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };
    }
    virtualHosts."185.170.113.195" = {
      listen = [{
        addr = "0.0.0.0";
        port = 3000;
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
      dnsProvider = "cloudflare";
      environmentFile = "${pkgs.writeText "cf-creds" ''
        CF_DNS_API_TOKEN_FILE=/run/secrets/cloudflare-dns-api-token
      ''}";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80, 3000 ];
}
