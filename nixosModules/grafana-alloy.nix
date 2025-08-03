{ pkgs, lib, config, ... }: {

  options = {
    grafana-alloy.enable = lib.mkEnableOption "enables grafana-alloy";
  };

  config = lib.mkIf config.grafana-alloy.enable {
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
  };
}
