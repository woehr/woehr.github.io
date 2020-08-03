#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (p: with p; [skylighting])"

import Skylighting

-- http://fixpt.de/blog/2017-12-03-hakyll-highlighting-themes.html
-- https://github.com/jgm/skylighting/blob/master/skylighting-core/src/Skylighting/Styles.hs

theme :: Style
theme = haddock

main :: IO ()
main = writeFile "./content/css/syntax.css" $ styleToCss theme
