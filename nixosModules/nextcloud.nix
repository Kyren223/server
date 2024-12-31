{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    nextcloud.enable = lib.mkEnableOption "enables nextcloud";
  };

  config = lib.mkIf config.nextcloud.enable {

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      useACMEHost = "kyren.codes";
    };

    # Define the password and disable php from caching the path to it
    sops.secrets.nextcloud-admin-password = { };
    services.nextcloud.phpOptions."realpath_cache_size" = "0";

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      hostName = "nextcloud.kyren.codes";
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };
    };
  };
}
