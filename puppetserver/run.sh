#!/bin/bash 

# script comptatible with CentOS 7
# docker run -i -t -v $(pwd):/data centos:centos7 /bin/bash --login

JBUNDLE="/opt/puppetlabs/server/bin/puppetserver ruby /opt/puppetlabs/server/data/puppetserver/jruby-gems/bin/bundle"
JGEM="/opt/puppetlabs/server/bin/puppetserver gem"

rpm -q puppetlabs-release-pc1 >/dev/null 2>&1 || yum install -y -q https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
rpm -q which >/dev/null 2>&1 || yum install -y -q which
rpm -q puppetserver >/dev/null 2>&1 || yum install -y -q puppetserver


if ! test -f puppet-gemlist.txt; then
  $JGEM list \
    --local --no-verbose | 
    sed -r 's/^([a-zA-Z0-9_-]+) \(([0-9\.]+).*\)/\1|\2/' | egrep -v '^(facter|puppet|hiera|io-console|psych|test-unit|jar-dependencies|jruby-openssl)\|' >puppet-gemlist.txt
fi

rm -f Gemfile.puppetprovided
for gem in $(cat puppet-gemlist.txt); 
do 
  name=$(echo $gem | cut -f1 -d\|); 
  version=$(echo $gem | cut -f2 -d\|); 
  echo "gem '$name', '$version'" >>Gemfile.puppetprovided
done



rpm -q make >/dev/null 2>&1 || yum install -y -q make
rpm -q vim-enhanced >/dev/null 2>&1 || yum install -y -q vim
rpm -q rpm-build >/dev/null 2>&1 || yum install -y -q rpm-build
rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc-c++ >/dev/null 2>&1 || yum install gcc -y -q
rpm -q gcc-g++ >/dev/null 2>&1 || yum install gcc-c++ -y -q


test -f /opt/puppetlabs/server/data/puppetserver/jruby-gems/bin/bundle || $JGEM install bundler

$JBUNDLE package

for gem in $(cat puppet-gemlist.txt); 
do 
  name=$(echo $gem | cut -f1 -d\|); 
  rm -f vendor/cache/${name}-*
done

for gem in $(cat puppet-gemlist.txt); 
do 
  name=$(echo $gem | cut -f1 -d\|); 
  echo "--gem-disable-dependency ${name} \\"
done

yum erase puppetserver puppet-agent -y -q && rm -rf /opt/puppetlabs && rm -f puppet-gemlist.txt
