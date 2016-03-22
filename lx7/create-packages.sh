#!/bin/sh

# start centos7 with docker:
# docker run -i -t -v $path-to-git-repo:/data centos:centos7 /bin/bash --login

set -e 

cd $(dirname $0)
test -d RPMS || mkdir RPMS

bundle package

cd RPMS 

find ../vendor/cache -name '*.gem' | xargs -rn1 fpm -d ruby -d rubygems \
  --prefix /usr/share/gems \
  --gem-bin-path /usr/bin \
  --epoch 0 --iteration 2.el7 -s gem -t rpm

# remove rubygems provided by RedHat
rm -f rubygem-json*

# workaround: gem version 1.2 is somehow converted to package version 1.2.0 
# which does not match generated dependencies
rm -f rubygem-colored-*
fpm -d ruby -d rubygems \
  --prefix /usr/share/gems \
  --gem-bin-path /usr/bin \
  --epoch 0 --version 1.2 --iteration 2.el7 -s gem -t rpm ../vendor/cache/colored-1.2.gem
