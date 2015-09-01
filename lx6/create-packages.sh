#!/bin/sh

set -e 

rpm -q which >/dev/null 2>&1 || yum install which -y -q
rpm -q git >/dev/null 2>&1 || yum install git -y -q
rpm -q vim >/dev/null 2>&1 || yum install vim -y -q

if ! which gem; then
  yum install rubygems -y
fi

if ! which bundle; then
  gem install bundler
fi

rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc >/dev/null 2>&1 || yum install gcc -y -q
rpm -q rpm-build >/dev/null 2>&1 || yum install rpm-build -y -q

if ! which fpm; then
  bundle install
fi

bundle package

find vendor/cache -name '*.gem' | xargs -rn1 fpm -d ruby -d rubygems \
  --prefix /usr/share/gems \
  --gem-bin-path /usr/bin \
  --epoch 0 --iteration 0.el6 -s gem -t rpm

