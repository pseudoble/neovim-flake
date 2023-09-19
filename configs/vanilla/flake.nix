{
  description = "A simple flake to launch a vanilla instance of Neovim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in 
      {
        packages.neovim = pkgs.neovim;
        defaultPackage = pkgs.neovim;
      }
    );
}
