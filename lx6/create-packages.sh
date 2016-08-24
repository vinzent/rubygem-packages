#!/bin/sh

# start centos6 with docker:
# docker run -i -t -v $path-to-git-repo:/data centos:centos6 /bin/bash --login

set -e 

mkdir RPMS || true


if ! which fpm; then
  bundle install
fi

bundle package

cd RPMS

find ../vendor/cache -name '*.gem' | xargs -rn1 fpm -d ruby -d rubygems \
  --prefix /usr/lib/ruby/gems/1.8 \
  --gem-bin-path /usr/bin \
  --epoch 0 --iteration 1.el6 -s gem -t rpm

