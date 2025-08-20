{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    stalwart.enable = lib.mkEnableOption "enables stalwart";
  };

  config = lib.mkIf config.stalwart.enable {

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 993 25 465 143 587 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    sops.secrets.cloudflare-email-token = { owner = "stalwart-mail"; group = "stalwart-mail"; };
    sops.secrets.stalwart-admin-password = { owner = "stalwart-mail"; group = "stalwart-mail"; };
    sops.secrets.stalwart-kyren-password = { owner = "stalwart-mail"; group = "stalwart-mail"; };
    sops.secrets.stalwart-postmaster-password = { owner = "stalwart-mail"; group = "stalwart-mail"; };

    services.nginx.virtualHosts."webadmin.kyren.codes" = {
      useACMEHost = "kyren.codes";
      # enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8081";
        proxyWebsockets = false; # enable true if websockets needed
        # any additional nginx proxy headers can be added below
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };

      serverAliases = [
        "mta-sts.kyren.codes"
        "autoconfig.kyren.codes"
        "autodiscover.kyren.codes"
        "mail.kyren.codes"
      ];
    };

    services.caddy = {
      enable = false;
      virtualHosts = {
        "webadmin.kyren.codes" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8081
          '';
          serverAliases = [
            "mta-sts.kyren.codes"
            "autoconfig.kyren.codes"
            "autodiscover.kyren.codes"
            "mail.kyren.codes"
          ];
        };
      };
    };

    services.stalwart-mail = {
      enable = true;
      package = pkgs.stalwart-mail;
      openFirewall = true;
      settings = {
        server = {
          hostname = "mx1.kyren.codes";
          tls = {
            enable = true;
            implicit = false;
          };
          listener = {
            smtp = {
              protocol = "smtp";
              # bind = "0.0.0.0:25,[::]:25";
              # bind = ["0.0.0.0:25" "[::]:25"];
              bind = [":25"];
            };
            submissions = {
              bind = "[::]:465";
              protocol = "smtp";
            };
            imaps = {
              # bind = "[::]:993";
              # bind = ["0.0.0.0:993" "[::]:993"];
              bind = [":993"];
              protocol = "imap";
            };
            # jmap = {
            #   bind = "[::]:8081";
            #   url = "https://mail.kyren.codes";
            #   protocol = "jmap";
            # };
            management = {
              bind = [ "127.0.0.1:8081" ];
              protocol = "http";
            };
          };
        };
        lookup.default = {
          hostname = "mx1.kyren.codes";
          domain = "kyren.codes";
        };
        acme."letsencrypt" = {
          directory = "https://acme-v02.api.letsencrypt.org/directory";
          challenge = "dns-01";
          contact = "user1@kyren.codes";
          domains = [ "kyren.codes" "mx1.kyren.codes" ];
          provider = "cloudflare";
          secret = "%{file:${config.sops.secrets.cloudflare-email-token.path}}%";
        };
        session.auth = {
          mechanisms = "[plain]";
          directory = "'in-memory'";
        };
        storage.directory = "in-memory";
        session.rcpt.directory = "'in-memory'";
        # queue.outbound.next-hop = "'local'";
        directory."imap".lookup.domains = [ "kyren.codes" ];
        directory."in-memory" = {
          type = "memory";
          principals = [
            {
              class = "individual";
              name = "kyren";
              secret = "%{file:${config.sops.secrets.stalwart-kyren-password.path}}%";
              email = [ "contact@kyren.codes" ];
            }
            {
              class = "individual";
              name = "postmaster";
              secret = "%{file:${config.sops.secrets.stalwart-postmaster-password.path}}%";
              email = [ "postmaster@kyren.codes" ];
            }
          ];
        };
        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:${config.sops.secrets.stalwart-admin-password.path}}%";
        };
      };
    };

  };
}
