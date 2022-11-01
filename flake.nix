{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;

        devShell = with pkgs;
          mkShell {
            buildInputs = [
              cargo
              rustc
              rustfmt
              pre-commit
              rustPackages.clippy
              pkgs.darwin.apple_sdk.frameworks.CoreAudio
              pkgs.darwin.apple_sdk.frameworks.CoreMIDI
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
            preConfigure = ''
              export NIX_LDFLAGS="-F${pkgs.darwin.apple_sdk.frameworks.CoreAudio}/Library/Frameworks -framework CoreAudio $NIX_LDFLAGS";
              export NIX_LDFLAGS="-F${pkgs.darwin.apple_sdk.frameworks.CoreMIDI}/Library/Frameworks -framework CoreMIDI $NIX_LDFLAGS";
            '';
          };
      });
}
