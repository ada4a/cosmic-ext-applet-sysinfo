{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nativeBuildInputs = with pkgs; [
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
        packages.default = pkgs.callPackage ./package.nix { };
        devShells.default = pkgs.mkShell {
          packages = nativeBuildInputs ++ buildInputs;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
        };
      }
    );
}
