{ pkgs, lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    stalwart.enable = lib.mkEnableOption "enables stalwart";
  };

  config = lib.mkIf config.stalwart.enable {

    # Open http and https ports to the public
    networking.firewall.allowedTCPPorts = [ 443 80 ];

    # Make sure acme module is active for the "kyren.codes" ssl cert
    acme.enable = true;

    environment.etc = {
      "stalwart/mail-pw1".text = "foobar";
      "stalwart/mail-pw2".text = "foobar";
      "stalwart/admin-pw".text = "foobar";
      "stalwart/acme-secret".text = "secret123";
    };

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
              bind = ["0.0.0.0:25" "[::]:25"];
            };
            submissions = {
              bind = "[::]:465";
              protocol = "smtp";
            };
            imaps = {
              bind = "[::]:993";
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
          secret = "%{file:/etc/stalwart/acme-secret}%";
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
              name = "User 1";
              secret = "%{file:/etc/stalwart/mail-pw1}%";
              email = [ "user1@kyren.codes" ];
            }
            {
              class = "individual";
              name = "postmaster";
              secret = "%{file:/etc/stalwart/mail-pw1}%";
              email = [ "postmaster@kyren.codes" ];
            }
          ];
        };
        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:/etc/stalwart/admin-pw}%";
        };
      };
    };

  };
}
