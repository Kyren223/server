{ pkgs, ... }: {
  # services.nginx = {
  #   enable = true;
  #   # virtualHosts."kyren.codes" = {
  #   #   forceSSL = true;
  #   #   enableACME = true;
  #   #   # useACMEHost = "kyren.codes";
  #   #   locations."/" = {
  #   #     proxyPass = "85.170.113.195:3000";
  #   #   };
  #   # };
  #
  #   virtualHosts."kyren.codes" = {
  #     forceSSL = true;
  #     enableACME = true;
  #     # listen = [{
  #     #   addr = "0.0.0.0";
  #     #   port = 3000;
  #     # }];
  #
  #     locations."/" = {
  #       index = "index.html";
  #       root = "/srv/website";
  #     };
  #
  #     # locations."/404.html" = {
  #     #   root = "/srv/website";
  #     # };
  #     # extraConfig = ''
  #     #   error_page 404 /404.html;
  #     # '';
  #
  #   };
  # };
  services.nginx.enable = true;
  services.nginx.virtualHosts."test.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/" = {
        index = "index.html";
        root = "/srv/website";
      };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "kyren223@proton.me";
    certs."kyren.codes" = {
      domain = "kyren.codes";
      extraDomainNames = [ "*.kyren.codes" ];
      dnsProvider = "cloudflare";
      environmentFile = "${pkgs.writeText "cf-creds" ''
        CF_DNS_API_TOKEN_FILE=/run/secrets/cloudflare-dns-api-token
      ''}";
      webroot = null;
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];

  networking.firewall.allowedTCPPorts = [ 443 80 3000 ];
}
