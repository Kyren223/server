{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
    "${fetchTarball {
    url = "https://github.com/onny/nixos-nextcloud-testumgebung/archive/fa6f062830b4bc3cedb9694c1dbf01d5fdf775ac.tar.gz";
    sha256 = "0gzd0276b8da3ykapgqks2zhsqdv4jjvbv97dsxg0hgrhb74z0fs";}}/nextcloud-extras.nix"
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
    sops.secrets.nextcloud-admin-password = { owner = "nextcloud"; group = "nextcloud"; };
    services.nextcloud.phpOptions."realpath_cache_size" = "0";

    sops.secrets.nextcloud-kyren-password = { owner = "nextcloud"; group = "nextcloud"; };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud29;
      hostName = "nextcloud.kyren.codes";
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };
      ensureUsers = {
        kyren = {
          email = "kyren223@proton.em";
          passwordFile = config.sops.secrets.nextcloud-kyren-password.path;
        };
      };
    };
  };
}
