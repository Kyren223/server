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
    networking.firewall.allowedTCPPorts = [ 443 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
      # useACMEHost = "kyren.codes";
    };

    # Define the password and disable php from caching the path to it
    sops.secrets.nextcloud-admin-password = { owner = "nextcloud"; group = "nextcloud"; };
    # services.nextcloud.phpOptions."realpath_cache_size" = "0";

    sops.secrets.nextcloud-kyren-password = { owner = "nextcloud"; group = "nextcloud"; };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = "nextcloud.kyren.codes";

      database.createLocally = true;
      configureRedis = true;

      maxUploadSize = "16G";
      https = true;
      # enableBrokenCiphersForSSE = false;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts mail notes tasks;

        # Custom app installation example.
        cookbook = pkgs.fetchNextcloudApp rec {
          url =
            "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
          sha256 = "sha256-XgBwUr26qW6wvqhrnhhhhcN4wkI+eXDHnNSm1HDbP6M=";
        };
      };

      settings = {
        overwrite_protocol = "https";
        default_phone_region = "PT";
      };

      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };
      # ensureUsers = {
      #   kyren = {
      #     email = "kyren223@proton.me";
      #     passwordFile = config.sops.secrets.nextcloud-kyren-password.path;
      #   };
      # };
    };
  };
}
