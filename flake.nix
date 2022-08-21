{
  description = "Daemon for displaying info in status bar";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    rust-overlay = { 
      url = "github:oxalica/rust-overlay"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlay ];
          };
        in
        {
          devShell = pkgs.mkShell rec {
            buildInputs = with pkgs; [
              rust-bin.stable.latest.default
              rust-analyzer
              rustfmt

              pkgconfig

              libpulseaudio
              dbus
            ];
            LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
          };

          defaultPackage = pkgs.rustPlatform.buildRustPackage {
            name = "rust-blocks";
            src = ./.;
            buildInputs = with pkgs; [ dbus libpulseaudio ];
            nativeBuildInputs = with pkgs; [ pkgconfig ];
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
          };
        });
}
