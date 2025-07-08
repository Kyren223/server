{ pkgs, lib, config, ... }: {

  options = {
    eko.enable = lib.mkEnableOption "enables eko";
  };

  config = lib.mkIf config.eko.enable {
    users.groups.eko = { };
    users.users.eko = {
      createHome = false;
      isNormalUser = true;
      group = "eko";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbntLELS9l2auPVZtCtQ6KYQNka72qDbTdkDtX9rkyJ"
      ];
    };

    # Open port 7223 for eko protocol, 443 for website
    networking.firewall.allowedTCPPorts = [ 7223 443 ];

    sops.secrets.eko-server-cert-key = { owner = "eko"; };

    environment.etc = {
      "eko/tos.md".text = builtins.readFile ./eko-tos.md;
      "eko/privacy.md".text = builtins.readFile ./eko-privacy.md;
    };

    systemd.services.eko = {
      description = "Eko - a secure terminal-based social media";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # restartTriggers = [ "/var/lib/eko/eko-server" ];
      reloadTriggers = lib.mapAttrsToList (_: v: v.source or null) (
        lib.filterAttrs (n: _: lib.hasPrefix "eko/" n) config.environment.etc
      );

      environment = {
        EKO_SERVER_CERT_FILE = config.sops.secrets.eko-server-cert-key.path;
        EKO_SERVER_LOG_DIR = "/var/log/eko";
      };

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";

        ExecStart = "%S/eko/eko-server";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";

        ConfigurationDirectory = "eko";
        StateDirectory = "eko";
        LogsDirectory = "eko";
        WorkingDirectory = "%S/eko";
        Type = "simple";

        User = "eko";
        Group = "eko";

        # Hardening
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    # Enable metrics/logging
    grafana.enable = true;
    loki.enable = true;

    environment.systemPackages = with pkgs; [
      grafana-alloy
    ];

    systemd.services.alloy = {
      description = "Alloy";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      reloadTriggers = lib.mapAttrsToList (_: v: v.source or null) (
        lib.filterAttrs (n: _: lib.hasPrefix "alloy/" n && lib.hasSuffix ".alloy" n) config.environment.etc
      );

      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";

        User = "root"; # TODO: make these not root?
        Group = "root";

        SupplementaryGroups = [
          # allow to read the systemd journal for loki log forwarding
          "systemd-journal"
        ];

        ConfigurationDirectory = "alloy";
        StateDirectory = "alloy";
        WorkingDirectory = "%S/alloy";
        Type = "simple";

        ExecStart = "${lib.getExe pkgs.grafana-alloy} run /etc/alloy/";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
      };
    };

    environment.etc = {
      "alloy/eko-config.alloy".text = builtins.readFile ./eko-config.alloy;
    };

    # # Make sure acme module is active for the "kyren.codes" ssl cert
    # acme.enable = true;
    #
    # # Website
    # services.nginx.enable = true;
    # services.nginx.virtualHosts."eko.kyren.codes" = {
    #   useACMEHost = "kyren.codes";
    #   forceSSL = true;
    #   locations."/".proxyPass = "http://localhost:7443/";
    # };

  };
}
