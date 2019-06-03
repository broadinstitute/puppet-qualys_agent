#!/usr/bin/env bash

export PUPPET_GEM_VERSION='< 6.0.0'

mv -f /tmp/global.yaml /etc/puppetlabs/code/hieradata/global.yaml
cd /etc/puppetlabs/code/modules/qualys_agent || exit
rm -f Gemfile.lock
rm -f Puppetfile.lock
bundle install
# librarian-puppet is busted in some way...
# librarian-puppet install --verbose --path=/etc/puppetlabs/code/modules
puppet module install puppetlabs-stdlib
