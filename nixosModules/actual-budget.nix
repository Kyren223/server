{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    actualBudget.enable = lib.mkEnableOption "enables actual-budget";
  };

  config = lib.mkIf config.actualBudget.enable {

    users.users.actualbudget = {
      createHome = false;
      isNormalUser = true;
      group = "users";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
      ];
      packages = with pkgs; [
        nodejs_22
        yarn
        gitMinimal
      ];
    };

    # Make sure the "website" user has access to /srv/website
    systemd.tmpfiles.rules = [
      "d /srv/actual-server 0700 actualbudget users"
    ];

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts."budget.kyren.codes" = {
        useACMEHost = "kyren.codes";
        forceSSL = true;

        locations."/".proxyPass = "http://localhost:5006/";
        # locations."/".extraConfig = ''
        #   include /config/nginx/proxy.conf;
        #   include /config/nginx/resolver.conf;
        #
        #   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #   proxy_set_header Host $host;
        # '';

    };
  };
}
