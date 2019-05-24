#!/usr/bin/env bash

export PUPPET_GEM_VERSION='< 6.0.0'

rpm --import https://yum.puppet.com/RPM-GPG-KEY-puppet
rpm --import https://yum.puppet.com/RPM-GPG-KEY-puppetlabs
yum -y install https://yum.puppet.com/puppet5-release-el-7.noarch.rpm
yum -y install git pdk puppet-agent vim
cp /tmp/Gemfile /etc/puppetlabs/code/
cp /tmp/hiera.yaml /etc/puppetlabs/code/
mkdir -p /etc/puppetlabs/code/hieradata
cp /tmp/global.yaml /etc/puppetlabs/code/hieradata/global.yaml
cp /tmp/pdk.sh /etc/profile.d/pdk.sh
gem install bundle librarian-puppet rake --no-rdoc --no-ri
bundle config --global silence_root_warning 1
mkdir -p /etc/puppetlabs/code/modules/qualys_agent
cd /etc/puppetlabs/code/modules/qualys_agent || exit
rm -f Gemfile.lock
bundle install
rm -f Puppetfile.lock
librarian-puppet install --verbose --path=/etc/puppetlabs/code/modules
