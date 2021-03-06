if ! which bundle; then
  yum install rubygem-bundler -y
fi

rpm -q make >/dev/null 2>&1 || yum install -y -q make
rpm -q vim >/dev/null 2>&1 || yum install -y -q vim
rpm -q rpm-build >/dev/null 2>&1 || yum install -y -q rpm-build
rpm -q ruby-devel >/dev/null 2>&1 || yum install ruby-devel -y -q
rpm -q gcc >/dev/null 2>&1 || yum install gcc -y -q
rpm -q gcc-g++ >/dev/null 2>&1 || yum install gcc-c++ -y -q

# for curb
rpm -q libcurl-devel >/dev/null 2>&1 || yum install libcurl-devel -y -q

# for rainbow (new dependency of r10k 2.5)
rpm -q rubygem-rake >/dev/null 2>&1 || yum install rubygem-rake -y -q

if ! which fpm; then
  bundle install
fi

