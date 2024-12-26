{ pkgs, ... }: {
  services = {
    getty.autologinUser = "root";
    nginx = {
      enable = true;
      virtualHosts.localhost.locations."/" = {
        index = "index.html";
        root = pkgs.writeTextDir "index.html" ''
          <html>
          <body>
          Hello, world!
          </body>
          </html>
        '';
      };
    };
  };
}
