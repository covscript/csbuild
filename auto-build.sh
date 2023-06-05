#!/bin/bash
function start ()
{
    ./build/bin/cs -i ./build/imports ./misc/auto_build.csc ./build-cache/$1
}
git_repo="https://github.com/"
function fetch_git ()
{
    if [ ! -d "${1#*/}" ]; then
        git clone $git_repo/$1 --depth=1
    else
        cd ${1#*/}
        git fetch
        git pull
        cd ..
    fi
}

CURRENT_FOLDER=$(dirname $(readlink -f "$0"))
export CS_DEV_PATH=${CURRENT_FOLDER}/build-cache/covscript/csdev
cd $CURRENT_FOLDER

if [[ "$#" = 1 && "$1" = "release" ]]; then
    echo "Building for release..."
    CSPKG_CONFIG="./misc/cspkg_config.json"
else
    echo "Building for nightly..."
    CSPKG_CONFIG="./misc/cspkg_nightly_config.json"
fi

bash ./misc/unix_build_minimal.sh $1

rm -rf ./build
mkdir -p build/bin
cd build-cache

# Setup basic environment

cp -rf cspkg/build .. &
cp -rf covscript/build .. &
cp -rf covscript/csdev/* ../build/ &
cp -rf covscript-curl/build .. &
cp -rf covscript-regex/build .. &
cp -rf covscript-codec/build .. &
cp -rf covscript-process/build .. &
wait

fetch_git covscript/csdbc &
fetch_git covscript/stdutils &
fetch_git covscript/covanalysis &
fetch_git covscript/covscript-darwin &
fetch_git covscript/covscript-sqlite &
fetch_git covscript/covscript-network &
fetch_git covscript/covscript-imgui &
fetch_git covscript/covscript-zip &
fetch_git covscript/covscript-database &
wait

cd ..

# Concurrent works

start stdutils &
start covanalysis &
start covscript-darwin &
start covscript-sqlite &
start covscript-network &
start covscript-imgui &
start covscript-zip &
start covscript-database &
wait

./build/bin/cs -i ./build/imports ./misc/cspkg_build.csc $CSPKG_CONFIG
if [[ "$#" != 1 || "$1" != "release" ]]; then
    ./build/bin/cs -i ./build/imports ./misc/replace_source.csc ./build/bin/cspkg
fi
cp -rf build-cache/ecs/build .
chmod +x ./build/bin/ecs
