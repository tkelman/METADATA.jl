#!/bin/sh
set -e
cd $(dirname $0)/..
git checkout -b localbranch
cd ..
ln -s $PWD/METADATA.jl METADATA
for ver in 0.4 0.5; do # releases
  mkdir -p ~/.julia/v$ver julia-$ver
  ln -s $PWD/METADATA.jl ~/.julia/v$ver/METADATA
  curl -L --retry 5 https://s3.amazonaws.com/julialang/bin/linux/x64/$ver/julia-$ver-latest-linux-x86_64.tar.gz | \
    tar -C julia-$ver --strip-components=1 -xzf - && \
    julia-$ver/bin/julia -e 'versioninfo(); include("METADATA/.test/METADATA.jl")' && \
    touch success-$ver &
done
# nightly, uncomment this once julia master is 0.6-dev
ver=0.6
mkdir -p ~/.julia/v$ver julia-$ver
ln -s $PWD/METADATA.jl ~/.julia/v$ver/METADATA
#curl -L --retry 5 https://s3.amazonaws.com/julianightlies/bin/linux/x64/julia-latest-linux64.tar.gz | \
#  tar -C julia-$ver --strip-components=1 -xzf - && \
#  julia-$ver/bin/julia -e 'versioninfo(); include("METADATA/.test/METADATA.jl")' && \
#  touch success-nightly &
wait
if ! [ -e success-0.4 -a -e success-0.5 ]; then
  exit 1
fi
