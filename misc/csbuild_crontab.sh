#!/bin/bash

# Where you installed
csbuild_home=/home/covscript/csbuild

# HTML Page
http_path=/var/www/html

# Update Scripts
cd $csbuild_home
git fetch
git pull
git clean -dfx

# Build .deb
cd deb_tools
bash auto-build.sh

# Install
architecture=`dpkg --print-architecture`
cp ./deb-src/*.deb $http_path/covscript-$architecture.deb