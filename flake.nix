{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      naersk,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        naersk' = pkgs.callPackage naersk { };

        nativeBuildInputs = with pkgs; [
          # rustc
          # cargo

          just
          pkg-config
          libxkbcommon
        ];
        # https://github.com/rust-windowing/winit/issues/4012
        # https://github.com/rust-windowing/winit/issues/3244
        # https://eu90h.com/wgpu-winit-and-nixos.html
        buildInputs = with pkgs; [
          wayland
        ];
      in
      {
        # For `nix build` & `nix run`:
        packages.default = naersk'.buildPackage {
          src = ./.;
          gitSubmodules = true;
        };

        # For `nix develop` (optional, can be skipped):
        devShell = pkgs.mkShell {
          packages = nativeBuildInputs ++ buildInputs;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      }
    );
}
