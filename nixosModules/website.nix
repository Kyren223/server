{ lib, config, pkgs, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    website.enable = lib.mkEnableOption "enables website";
  };

  config = lib.mkIf config.website.enable {

    sops.secrets.website-my-uptime-token = { owner = "website"; group = "website"; };

    users.groups.website = { };
    users.users.website = {
      isSystemUser = true;
      group = "website";
      home = "/var/lib/website";
      createHome = true;
      shell = pkgs.bashInteractive;
      useDefaultShell = false;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1B/i/AQLYt6mrz0P/oUJItpvWXp7z0xHNzmcPdtwWd"
      ];
    };

    systemd.services.website = {
      description = "Website";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "website";
        Group = "website";
        WorkingDirectory = "/var/lib/website";
        ExecStart = "/var/lib/website/website";
        Restart = "always";
        RestartSec = "3s";

        Environment = [
          "MY_UPTIME_TOKEN_FILE=${config.sops.secrets.website-my-uptime-token.path}"
        ];

        # Hardening
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
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

    security.sudo.extraRules = [{
        users = [ "website" ];
        commands = [{
            command = "/run/current-system/sw/bin/systemctl restart website";
            options = [ "NOPASSWD" ];
        }];
    }];

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts."kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7331";
      };
    };
  };
}
