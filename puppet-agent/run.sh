#!/bin/bash 

# script comptatible with CentOS 7
# docker run -i -t -v $(pwd):/data centos:centos7 /bin/bash --login

rpm -q puppetlabs-release-pc1 >/dev/null 2>&1 || yum install -y -q https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
rpm -q puppet-agent >/dev/null 2>&1 || yum install -y -q puppet-agent


if ! test -f puppet-agent-gemlist.txt; then
  /opt/puppetlabs/puppet/bin/gem list \
    --local --no-verbose | 
    sed -r 's/^([a-zA-Z0-9_-]+) \(([0-9\.]+)\)/\1|\2/' | egrep -v '^(facter|puppet|hiera|io-console|psych|test-unit)\|' >puppet-agent-gemlist.txt
fi

rm -f Gemfile.puppetagentprovided
for gem in $(cat puppet-agent-gemlist.txt); 
do 
  name=$(echo $gem | cut -f1 -d\|); 
  version=$(echo $gem | cut -f2 -d\|); 
  echo "gem '$name', '$version'" >>Gemfile.puppetagentprovided
done



rpm -q which >/dev/null 2>&1 || yum install -y -q which
rpm -q make >/dev/null 2>&1 || yum install -y -q make
rpm -q vim-enhanced >/dev/null 2>&1 || yum install -y -q vim
rpm -q rpm-build >/dev/null 2>&1 || yum install -y -q rpm-build
rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc-c++ >/dev/null 2>&1 || yum install gcc -y -q
rpm -q gcc-g++ >/dev/null 2>&1 || yum install gcc-c++ -y -q


test -f /opt/puppetlabs/puppet/bin/bundle || /opt/puppetlabs/puppet/bin/gem install bundler

/opt/puppetlabs/puppet/bin/bundle package

for gem in $(cat puppet-agent-gemlist.txt); 
do 
  name=$(echo $gem | cut -f1 -d\|); 
  rm -f vendor/cache/${name}-*
done

for gem in $(cat puppet-agent-gemlist.txt); 
do 
  name=$(echo $gem | cut -f1 -d\|); 
  echo "--gem-disable-dependency ${name} \\"
done

yum erase puppet-agent -y && rm -rf /opt/puppetlabs/puppet/ && rm -f puppet-agent-gemlist.txt
