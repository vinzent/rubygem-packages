#!/bin/sh

set -e 

if ! which bundle; then
  yum install rubygem-bundler -y
fi

rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc >/dev/null 2>&1 || yum install gcc -y -q

if ! which fpm; then
  bundle install
fi

bundle package

find vendor/cache -name '*.gem' | xargs -rn1 fpm -d ruby -d rubygems \
  --prefix /usr/share/gems \
  --gem-bin-path /usr/bin \
  --epoch 0 --iteration 0.el7 -s gem -t rpm

# remove rubygems provided by RedHat
rm -f rubygem-json*

# workaround: gem version 1.2 is somehow converted to package version 1.2.0 
# which does not match generated dependencies
rm -f rubygem-colored-*
fpm -d ruby -d rubygems \
  --prefix /usr/share/gems \
  --gem-bin-path /usr/bin \
  --epoch 0 --version 1.2 --iteration 0.el7 -s gem -t rpm vendor/cache/colored-1.2.gem
