#!/bin/bash 

echo ghc
echo cabal-install
echo haddock
pacman -Ss 'haskell-' | sed -n 's/^.*\/\(haskell-[^ ]*\) .*$/\1/p'
