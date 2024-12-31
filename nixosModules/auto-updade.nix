{ pkgs, lib, config, ... }: {

  options = {
    autoUpdate.enable = lib.mkEnableOption "enables autoUpdate";
  };

  config = lib.mkIf config.autoUpdate.enable {

    # PAT to be able to access the repo
    sops.secrets.github-access-token = { };
    nix.extraOptions = "!include ${config.sops.secrets.github-access-token.path}";

    system.autoUpgrade = {
      enable = true;
      flake = "github:kyren223/server#default";
      dates = "minutely"; # Poll interval
      flags = [
        "--impure"
        "--no-write-lock-file" # Prevent flake.lock from upgrading
        "--option" "tarball-ttl" "0" # Required for polling below 1h
      ];
    };
  };
}
