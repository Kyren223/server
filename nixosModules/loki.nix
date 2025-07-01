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
        interface_names = [ "ens3" ];
        # added ens3 whichi s the interface in netcup
        ring = {
          instance_addr = "127.0.0.1";
          kvstore = {
            store = "inmemory";
          };
          instance_interface_names = [ "eth0" "en0" "ens3" ];
          # added ens3 whichi s the interface in netcup
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
