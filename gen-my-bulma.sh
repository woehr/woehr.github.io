#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix
cp $(nix-build ./my-bulma.nix --no-out-link)/mybulma.min.css ./content/css/
