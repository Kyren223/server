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

    # Make sure the "eko" user has access to /srv/eko
    systemd.tmpfiles.rules = [
      "d /srv/eko 0750 eko eko"
    ];

    # Open port for the server to listen on
    networking.firewall.allowedTCPPorts = [ 7223 ];

    sops.secrets.eko-server-cert-key = { owner = "eko"; };

    systemd.services.eko = {
      description = "Eko (a secure terminal-based social media)";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        cd /srv/eko
        SERVER_CERT_KEY_FILE=${config.sops.secrets.eko-server-cert-key.path} ./eko-server --stdout
      '';

      serviceConfig = {
        User = "eko";
        Group = "eko";

        # Hardening
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = [ "/srv/eko" ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        Restart = "always";
        RestartSec = "10s";
      };
    };

    # Enable metrics/logging
    grafana.enable = true;
    loki.enable = false;
    services.alloy.enable = false;
    services.alloy.configPath = "/etc/alloy/config.alloy";

    environment.systemPackages = with pkgs; [
      grafana-alloy
    ];

    users.groups.alloy = { };
    users.users.alloy = {
      createHome = false;
      isNormalUser = true;
      group = "alloy";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbntLELS9l2auPVZtCtQ6KYQNka72qDbTdkDtX9rkyJ"
      ];
    };
    systemd.services.alloy = {
      description = "Alloy";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Restart = "always";
        RestartSec = "2s";

        User = "root";
        Group = "root";

        SupplementaryGroups = [
          # allow to read the systemd journal for loki log forwarding
          "systemd-journal"
        ];

        ConfigurationDirectory = "alloy";
        StateDirectory = "alloy";
        WorkingDirectory = "%S/alloy";
        Type = "simple";

        ExecStart = "${pkgs.grafana-alloy} run /etc/alloy/config.alloy";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
      };
    };

    environment.etc = {
      "alloy/config.alloy".text = builtins.readFile ./eko-config.alloy;
    };

  };
}
