let
  pkgsTarball = https://nixos.org/channels/nixos-20.03/nixexprs.tar.xz;
in
  { pkgs ? import (fetchTarball pkgsTarball) {} }:
  let
    generatorSrc = pkgs.nix-gitignore.gitignoreSource ["content" "default.nix" "shell.nix"] ./.;
    generator = pkgs.haskellPackages.callCabal2nix "woehr-github-io" generatorSrc {};
  in
    pkgs.stdenv.mkDerivation {
      name = "compiled-site";
      src = ./content;
      buildInputs = with pkgs; [
        glibcLocales
        generator
      ];
      phases = [ "buildPhase" "installPhase" ];
      LANG = "en_US.UTF-8";
      buildPhase = ''
        HAKYLL_PROVIDER_DIR=$src site build
      '';
      installPhase = ''
        mkdir $out
        cp -r _site/* $out
      '';
    }
