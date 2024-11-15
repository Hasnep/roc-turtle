{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    roc.url = "github:roc-lang/roc?rev=b7c2cb084e15a56320e652ad3c77fdb8262bc1a4";
  };

  nixConfig = {
    extra-trusted-public-keys = "roc-lang.cachix.org-1:6lZeqLP9SadjmUbskJAvcdGR2T5ViR57pDVkxJQb8R4=";
    extra-trusted-substituters = "https://roc-lang.cachix.org";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      roc,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem =
        { inputs', pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "roc-turtle";
            packages = [
              inputs'.roc.packages.cli
              pkgs.actionlint
              pkgs.check-jsonschema
              pkgs.fd
              pkgs.just
              pkgs.nixfmt-rfc-style
              pkgs.nodePackages.prettier
              pkgs.nodePackages.svgo
              pkgs.pre-commit
              pkgs.python312Packages.pre-commit-hooks
              pkgs.ratchet
            ];
            shellHook = "pre-commit install --overwrite";
          };
          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
