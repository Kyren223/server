{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix/bd695cc4d0a5e1bead703cc1bec5fa3094820a81";
    eko.url = "github:kyren223/eko/v0.1.0";
  };

  outputs = { nixpkgs, disko, sops-nix, eko, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        eko.nixosModules.eko
        ./host/configuration.nix
        ./host/hardware-configuration.nix
      ];
    };
  };
}
