let
  pkgsTarball = https://nixos.org/channels/nixos-20.03/nixexprs.tar.xz;
in
  { pkgs ? import (fetchTarball pkgsTarball) {} }:
  let
    generatorSrc = pkgs.nix-gitignore.gitignoreSource ["content" "default.nix" "shell.nix"] ./.;
    generator = pkgs.haskellPackages.callCabal2nix "woehr-github-io" generatorSrc {};
  in
    pkgs.haskellPackages.shellFor {
      packages = _: [ generator ];
      buildInputs = with pkgs.haskellPackages; [ cabal-install ];
    }
