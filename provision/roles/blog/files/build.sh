#!/bin/bash

set -e

SYSTEM_PACKAGES="\
    rubygems \
    ruby-dev \
    git-core \
    locales \
    make \
    gcc \
    zlib1g-dev \
    npm \
    nodejs-legacy"

cd /root

apt-get update
apt-get install -y $SYSTEM_PACKAGES

export PATH="$PATH:/root/.gem/ruby/2.1.0/bin:/root/node_modules/bower/bin"
npm install bower
gem install --no-ri --no-rdoc --user jekyll jemoji jekyll-sitemap

# Set locale to UTF-8, otherwise sass complains
echo 'en_US.UTF-8 UTF-8' >/etc/locale.gen
locale-gen
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

cd /app
bower install --allow-root
jekyll build
mv /app/_site /
mv /app/run.sh /
cd /
rm -rf /app
cd _site
rm -f Dockerfile Vagrantfile build.sh run.sh

apt-get purge -y $SYSTEM_PACKAGES
apt-get autoremove -y --purge
apt-get clean
rm -rf /root/.gem /root/node_modules /root/.npm
