{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    website.enable = lib.mkEnableOption "enables website";
  };

  config = lib.mkIf config.website.enable {

    users.users.website = {
      createHome = false;
      isNormalUser = true;
      group = "users";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1B/i/AQLYt6mrz0P/oUJItpvWXp7z0xHNzmcPdtwWd"
      ];
    };

    # Make sure the "website" user has access to /srv/website
    systemd.tmpfiles.rules = [
      "d /srv/website 0750 website users"
    ];

    # Set secrets for CD (let github actions upload builds to /srv/website)
    sops.secrets.github-access-token = { };
    nix.extraOptions = "!include /run/secrets/github-access-token";


    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyrej.codes" ssl cert
    acme.enable = true;

    services.nginx.enable = true;
    services.nginx.virtualHosts."kyren.codes" = {
        useACMEHost = "kyren.codes";
        forceSSL = true;
        locations."/" = {
          index = "index.html";
          root = "/srv/website";
        };

        locations."/404.html" = {
          root = "/srv/website";
        };
        extraConfig = ''
          error_page 404 /404.html;
        '';
    };

  };
}
