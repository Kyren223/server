{ pkgs, ... }: {
  services = {
    getty.autologinUser = "root";
    nginx = {
      enable = true;
      virtualHosts."185.170.113.195".locations."/" = {
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
