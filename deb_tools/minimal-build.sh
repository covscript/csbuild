#!/bin/bash
bash ./build_minimal.sh
bash ./install__minimal.sh
version_prefix=`./build/bin/cs -v | grep "^Version: " | awk '{print $2}'`
version_suffix=`./build/bin/cs -v | grep "^Version: " | awk '{print $NF}'`
architecture=`dpkg --print-architecture`
bash ./make-deb.sh /usr $architecture ${version_prefix}"."${version_suffix}"-minimal"