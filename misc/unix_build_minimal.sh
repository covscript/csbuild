#!/bin/bash
function start ()
{
    cd $1
    bash $2
    cd ..
}
mkdir -p build-cache
cd build-cache
git_repo="https://github.com/"
function clone_git ()
{
    if [ ! -d "${1#*/}" ]; then
        git clone $git_repo/$1
    fi
}
function fetch_git ()
{
    if [ ! -d "${1#*/}" ]; then
        git clone $git_repo/$1 --depth=1
    else
        cd ${1#*/}
        git fetch
        git pull
        git clean -dfx
        cd ..
    fi
}
clone_git covscript/covscript
if [[ "$#" == 1 && "$1" = "release" ]]; then
    CSPKG_CONFIG="./misc/cspkg_config.json"
    cd covscript
    git checkout 3.4.1
    cd ..
else
    CSPKG_CONFIG="./misc/cspkg_nightly_config.json"
    cd covscript
    git checkout master
    cd ..
    fetch_git covscript/covscript &
fi
fetch_git covscript/ecs &
fetch_git covscript/cspkg &
fetch_git covscript/covscript-regex &
fetch_git covscript/covscript-codec &
fetch_git covscript/covscript-curl &
fetch_git covscript/covscript-process &
wait
start cspkg "./csbuild/make.sh"
start covscript "./csbuild/make.sh"
# Concurrent works
start ecs "./csbuild/make.sh" &
start covscript-regex "./csbuild/make.sh" &
start covscript-codec "./csbuild/make.sh" &
start covscript-curl "./csbuild/make.sh" &
start covscript-process "./csbuild/make.sh" &
wait