{ pkgs, lib, config, ... }: {

  options = {
    MODULE.enable = lib.mkEnableOption "enables MODULE";
  };

  config = lib.mkIf config.MODULE.enable {
  };
}
