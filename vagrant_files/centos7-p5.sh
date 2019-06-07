#!/usr/bin/env bash

export PUPPET_GEM_VERSION='< 6.0.0'

mv -f /tmp/global.yaml /etc/puppetlabs/code/hieradata/global.yaml
mkdir -p /usr/local/bundle
echo 'export BUNDLE_PATH=/usr/local/bundle' > /etc/profile.d/bundle.sh
cd /etc/puppetlabs/code/modules/qualys_agent || exit
rm -f Gemfile.lock
rm -f Puppetfile.lock
bundle install --with development --without system_tests --path=${BUNDLE_PATH:-vendor/bundle}
# librarian-puppet is busted in some way...
# librarian-puppet install --verbose --path=/etc/puppetlabs/code/modules
bundle exec puppet module install puppetlabs-stdlib
