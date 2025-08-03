{ lib, config, ... }: {

  imports = [
    ./grafana-alloy.nix
  ];

  options = {
    eko.enable = lib.mkEnableOption "enables eko";
  };

  config = lib.mkIf config.eko.enable {
    sops.secrets.eko-server-cert-key = { owner = "eko"; };

    services.eko.enable = true;
    services.eko.certFile = config.sops.secrets.eko-server-cert-key.path;
    services.eko.openFirewall = true;

    environment.etc = {
      "eko/tos.md".text = builtins.readFile ./eko-tos.md;
      "eko/privacy.md".text = builtins.readFile ./eko-privacy.md;
    };

    # Add my ssh key
    users.users.eko.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
    ];

    # Allow grafana access to the sqlite db
    users.users.eko.group = lib.mkForce "grafana";
    systemd.tmpfiles.rules = [ "d /var/lib/eko 0750 eko grafana -" ];
    systemd.services.eko.serviceConfig.StateDirectoryMode = lib.mkForce "0750";
    systemd.services.grafana = {
      serviceConfig = {
        ProtectHome = lib.mkForce false;
        ProtectSystem = lib.mkForce false;
        PrivateTmp = lib.mkForce false;
        ReadWritePaths = [ "/var/lib/eko" ];
      };
    };

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    # Configure reverse proxy for the website
    services.nginx.enable = true;
    services.nginx.virtualHosts."eko.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:7443/";
    };

    # Monitoring/observibility
    grafana.enable = true; # dashboard
    loki.enable = true; # logging
    services.prometheus.enable = true; # metrics
    services.prometheus.configText = builtins.readFile ./eko-prometheus.yml;
    grafana-alloy.enable = true; # collector

  };
}
