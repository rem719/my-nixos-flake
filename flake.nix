{
  description = "Phloria's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    prism-cracked.url = "github:Diegiwg/PrismLauncher-Cracked";

    anime-games-launcher.url = "github:an-anime-team/anime-games-launcher";

    helium-browser.url = "github:schembriaiden/helium-browser-nix-flake";

    nix-antigravity.url = "github:hieu313/nix-antigravity";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-gaming,
    nix-cachyos-kernel,
    prism-cracked,
    anime-games-launcher,
    helium-browser,
    nix-antigravity,
    chaotic,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
      };

      modules = [
        nix-gaming.nixosModules.platformOptimizations
        anime-games-launcher.nixosModules.anime-games-launcher

        ({...}: {
          nixpkgs.overlays = [
            nix-cachyos-kernel.overlays.pinned

            (final: prev: {
              windowmaker = prev.windowmaker.overrideAttrs (old: {
                patches =
                  (old.patches or [])
                  ++ [
                    ./windowmaker-randr.patch
                  ];
              });

              dockapps =
                prev.dockapps
                // {
                  wmcube = prev.dockapps.wmcube.overrideAttrs (old: {
                    postPatch = ''
                      substituteInPlace wmcube.c \
                        --replace-fail "/usr/share/wmcube/" \
                        "${placeholder "out"}/share/wmcube/"
                    '';
                  });
                };
            })
          ];
        })

        ./configuration.nix
        chaotic.nixosModules.default
      ];
    };
  };
}
