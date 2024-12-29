{ pkgs, lib, config, ... }: {

  options = {
    acme.enable = lib.mkEnableOption "enables acme";
  };

  config = lib.mkIf config.acme.enable {
    sops.secrets.cloudflare-dns-api-token = { mode = "0440"; owner = "acme"; };

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "kyren223@proton.me";

    security.acme.certs."kyren.codes" = {
      domain = "kyren.codes";
      extraDomainNames = [ "*.kyren.codes" ];
      dnsProvider = "cloudflare";
      environmentFile = "${pkgs.writeText "cf-creds" ''
        CF_DNS_API_TOKEN_FILE=/run/secrets/cloudflare-dns-api-token
      ''}";
      webroot = null;
    };

    # Allow nginx to access acme certs
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
