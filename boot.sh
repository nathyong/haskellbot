#!/bin/sh

mkdir -p sandbox
cd sandbox
cabal sandbox init --sandbox .
cd ..

for d in lambdabot*
do
    cd "$d"
    cabal sandbox init --sandbox ../sandbox
    cd ..
done

for d in lambdabot-core lambdabot-trusted lambdabot-*-plugins lambdabot
do
    echo
    echo "==> Now processing: $d"
    cd "$d"
    cabal install --only-dependencies -j4
    cabal configure
    cabal install -j4
    cd ..
done
