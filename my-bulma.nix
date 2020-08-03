let
  # 20.03 doesn't have clean-css-cli, but unstable does
  #pkgsTarball = https://nixos.org/channels/nixos-20.03/nixexprs.tar.xz;
  pkgsTarball = https://releases.nixos.org/nixpkgs/nixpkgs-20.09pre236841.181179c53b7/nixexprs.tar.xz;
in
  { pkgs ? import (fetchTarball pkgsTarball) {} }:
  let
    inherit (pkgs) fetchzip writeText;

    bulma-ver = "0.9.0";
    bulma-src = "https://github.com/jgthms/bulma/releases/download/${bulma-ver}/bulma-${bulma-ver}.zip";
    bulma-hash = "0czi4j7by5nj6pxlqy6yjqhf8lqy1v7l720xrl1fjim9ms99v98l";

    bulma-vars = writeText "mybulma.scss" ''
      @charset "utf-8";

      // https://jenil.github.io/bulmaswatch/

      ////////////////////////////////////////////////
      // SPACELAB
      ////////////////////////////////////////////////
      $grey-darker: #2d2d2d;
      $grey-dark: #333;
      $grey: #777;
      $grey-light: #999;
      $grey-lighter: #eee;

      $orange: #d47500;
      $green: #3cb521;
      $blue: #3399f3;
      $red: #cd0200;

      $primary: #446e9b !default;
      $warning: $orange;
      $warning-invert: #fff;
      $link: #807f7f;

      $family-sans-serif: "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;

      $subtitle-color: $grey;

      $navbar-item-active-color: $primary;
      $navbar-item-hover-background-color: transparent;

      @import "./bulma.sass";
    '';
  in
    pkgs.stdenv.mkDerivation {
      name = "my-bulma";
      src = fetchzip { url = bulma-src; sha256 = bulma-hash; };
      buildInputs = with pkgs; [ sass yuicompressor nodePackages.clean-css-cli ];
      phases = [ "unpackPhase" "buildPhase" "installPhase" ];
      buildPhase = ''
        cp ${bulma-vars} ./mybulma.scss
        sass --sourcemap=none ./mybulma.scss:./mybulma.css
        cleancss -O2 -o ./mybulma.min.css ./mybulma.css
      '';

      installPhase = ''
        mkdir $out
        cp mybulma.min.css $out
      '';
    }
