{
  description = "A Nix-flake-based demo env";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # latest stable version at this time

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [ "aarch64-darwin" ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [ ];
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              ansible
              opentofu
              cnspec
            ];

            shellHook = ''
              echo "Hello Demo!"
            '';
          };
        }
      );
    };
}
