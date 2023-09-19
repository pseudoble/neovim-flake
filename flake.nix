{
  description = "Merged Neovim flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    config-standard.url = "./configs/standard";
  };

  outputs = { 
    self
    , nixpkgs
    , flake-utils
    , config-standard
    , }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in 
      {
        packages = rec {
          default = pkgs.neovim;
          standard = config-standard.packages.${system}.default;
        };
        apps = {
          default = { type = "app"; program = "${pkgs.neovim}/bin/nvim"; };
          standard = config-standard.apps.${system}.default;
        };
      }
    );
}
