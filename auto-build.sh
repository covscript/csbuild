#!/bin/bash
CURRENT_FOLDER=$(dirname $(readlink -f "$0"))
export CS_DEV_PATH=${CURRENT_FOLDER}/build-cache/covscript/csdev
cd $CURRENT_FOLDER
bash ./misc/unix_build.sh

rm -rf ./build
mkdir -p build/bin
cd build-cache

cp -rf cspkg/build ..
cp -rf covscript/build ..
cp -rf covscript/csdev/* ../build/
cp -rf covscript-regex/build ..
cp -rf covscript-codec/build ..
cp -rf covscript-process/build ..

cd ..
./build/bin/cs -i ./build/imports ./misc/cspkg_build.csc ./misc/cspkg_config.json