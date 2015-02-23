#!/bin/bash

set -e

rm -rf /usr/share/nginx/html

apt-get update
apt-get install -y curl ruby1.9.1-dev rubygems git-core locales zlib1g-dev

curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

npm install -g bower
gem install --no-ri --no-rdoc jekyll jemoji jekyll-sitemap

# Set locale to UTF-8, otherwise sass complains
echo 'en_US.UTF-8 UTF-8' >/etc/locale.gen
locale-gen
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

cd /app
bower install --allow-root
jekyll build
mv /app/_site /usr/share/nginx/html
cd /
rm -rf /app

yes | gem uninstall -a $(gem list --local | grep -v 'LOCAL' | awk '{print $1}')
apt-get purge -y curl ruby1.9.1-dev rubygems nodejs libstdc++6-4.7-dev dpkg-dev libc-dev-bin libc6-dev linux-libc-dev manpages-dev
apt-get autoremove -y --purge
apt-get clean
