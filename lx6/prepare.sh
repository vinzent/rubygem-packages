#!/bin/sh

# start centos6 with docker:
# docker run -i -t -v $path-to-git-repo:/data centos:centos6 /bin/bash --login

set -e 

yum_install() {
  rpm -q $1 >/dev/null 2>&1 || yum install $1 -y -q
}

yum_install which
yum_install git
yum_install vim
yum_install curl-devel
yum_install vim
yum_install rubygems
yum_install rpm-build
yum_install gcc


if ! which bundle; then
  gem install bundler
fi

rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc >/dev/null 2>&1 || yum install gcc -y -q
rpm -q rpm-build >/dev/null 2>&1 || yum install rpm-build -y -q

if ! which fpm; then
  bundle install
fi
