{
  description = "Phloria's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nix-gaming = {
  url = "github:fufexan/nix-gaming";
  inputs.nixpkgs.follows = "nixpkgs";
  };
};

  outputs = { self, nixpkgs, nix-gaming, nix-cachyos-kernel }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

 specialArgs = {
        inherit nix-gaming;
      };

      modules = [
        nix-gaming.nixosModules.platformOptimizations

	 ({ ... }: {
          nixpkgs.overlays = [
            nix-cachyos-kernel.overlays.pinned
          ];
        })


        ./configuration.nix
      ];
    };
  };
}
