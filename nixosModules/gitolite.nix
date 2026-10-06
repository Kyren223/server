{ lib, config, ... }: {

  imports = [
    ./acme.nix
  ];

  options = {
    gitolite.enable = lib.mkEnableOption "enables gitolite";
  };

  config = lib.mkIf config.gitolite.enable {
    users.groups.git = { };
    users.users.git = {
      isSystemUser = true;
      group = "git";
      home = "/var/lib/gitolite";
    };

    services.gitolite = {
      enable = true;
      user = "git";
      group = "git";
      adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7P9K9D5RkBk+JCRRS6AtHuTAc6cRpXfRfRMg/Kyren";
      extraGitoliteRc = ''
        $RC{UMASK} = 0027;
        $RC{GITWEB_PROJECTS_LIST} = '/var/lib/gitolite/projects.list';
        push @{ $RC{POST_PERMS} }, 'update-projects-list';
      '';
    };

    # Ensure cgit and nginx has perms to read gitolite repos
    users.users.cgit.extraGroups = [ "git" ];
    users.users.nginx.extraGroups = [ "git" ];

    services.cgit."git.kyren.codes" = {
      enable = true;
      gitHttpBackend.enable = false;
      repos = { testing = { path = "/var/lib/gitolite/testing.git"; }; };
      extraConfig = ''
        project-list=/var/lib/gitolite/projects.list
        scan-path=/var/lib/gitolite/repositories
        css=/custom-cgit.css
      '';
      nginx.location = "/";
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."git.kyren.codes" = {
      useACMEHost = "kyren.codes";
      forceSSL = true;
      locations."= /custom-cgit.css" = {
        alias = "${./cgit.css}";
      };
    };

  };
}
