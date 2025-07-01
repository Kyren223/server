{ lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    loki.enable = lib.mkEnableOption "enables loki";
  };

  config = lib.mkIf config.loki.enable {
    services.loki.enable = true;
    services.loki.configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
      };

      common = {
        ring = {
          instance_addr = "::1";
          kvstore = {
            store = "memberlist";
          };
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };

      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };

    };
  };
}
