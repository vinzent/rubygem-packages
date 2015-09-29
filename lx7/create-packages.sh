#!/bin/sh

# start centos7 with docker:
# docker run -i -t -v $path-to-git-repo:/data centos:centos7 /bin/bash --login

set -e 

if ! which bundle; then
  yum install rubygem-bundler -y
fi

rpm -q make >/dev/null 2>&1 || yum install -y -q make
rpm -q vim >/dev/null 2>&1 || yum install -y -q vim 
rpm -q rpm-build >/dev/null 2>&1 || yum install -y -q rpm-build
rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc >/dev/null 2>&1 || yum install gcc -y -q

if ! which fpm; then
  bundle install
fi

bundle package

find vendor/cache -name '*.gem' | xargs -rn1 fpm -d ruby -d rubygems \
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
  --epoch 0 --version 1.2 --iteration 2.el7 -s gem -t rpm vendor/cache/colored-1.2.gem
