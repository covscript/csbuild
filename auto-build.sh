#!/bin/bash
SHELL_FOLDER=$(dirname $(readlink -f "$0"))

function start ()
{
    cd $1
    bash $2
    cd ..
}

cd $SHELL_FOLDER
mkdir -p build-cache
cd build-cache

git_repo="https://github.com/covscript"

function fetch_git ()
{
    if [ ! -d "$1" ]; then
        git clone $git_repo/$1 --depth=1
    else
        cd $1
        git fetch
        git pull
        git clean -dfx
        cd ..
    fi
}

fetch_git cspkg &
fetch_git covscript &
fetch_git covscript-regex &
fetch_git covscript-codec &
fetch_git covscript-process &
wait

start cspkg "./csbuild/make.sh" &
start covscript "./csbuild/make.sh"
export CS_DEV_PATH=${SHELL_FOLDER}/build-cache/covscript/csdev
start covscript-regex "./csbuild/make.sh" &
start covscript-codec "./csbuild/make.sh" &
start covscript-process "./csbuild/make.sh" &
wait

cd ..
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
./build/bin/cs -i ./build/imports csbuild.csc $1