{ pkgs, lib, config, ... }: {

  options = {
    autoUpdate.enable = lib.mkEnableOption "enables autoUpdate";
  };

  config = lib.mkIf config.autoUpdate.enable {
    system.autoUpgrade = {
      enable = true;
      flake = "github:kyren223/server#default";
      dates = "minutely"; # Poll interval
      flags = [
        "--no-write-lock-file" # Prevent flake.lock from upgrading
        "--option" "tarball-ttl" "0" # Required for polling below 1h
      ];
    };
  };
}
