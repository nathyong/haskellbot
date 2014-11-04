#!/bin/sh

git pull origin

cabal sandbox init --sandbox sandbox

for d in lambdabot*
do
    (cd "$d" && cabal sandbox init --sandbox ../sandbox)
done

cabal install lambdabot-core/ lambdabot-trusted/ lambdabot-*-plugins/ lambdabot/
