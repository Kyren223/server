{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    wakapi.enable = lib.mkEnableOption "enables wakapi";
  };

  config = lib.mkIf config.wakapi.enable {

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts."waka.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3003/";
    };

    users.groups.wakapi = { };
    users.users.wakapi = {
      isSystemUser = true;
      group = "wakapi";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
      ];
      packages = with pkgs; [
        wakapi
        sqlite
      ];
    };

    # environment.etc."/var/lib/wakapi/config.yml".text = ./wakapi.yml;

    systemd.services.wakapi = {
      description = "Wakapi (self-hosted WakaTime-compatible backend)";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        cp ${./wakapi.yml} config.yml
        ${pkgs.wakapi}/bin/wakapi -config config.yml
      '';

      serviceConfig = {
        User = config.users.users.wakapi.name;
        Group = config.users.users.wakapi.group;
        DynamicUser = true;
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
        StateDirectory = "wakapi";
        StateDirectoryMode = "0700";
        Restart = "always";
      };
    };

  };
}
