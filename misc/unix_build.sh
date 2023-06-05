#!/bin/bash
function start ()
{
    ../build/bin/cs -i ../build/imports ../misc/auto_build.csc $1
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
        cd ..
    fi
}
clone_git covscript/covscript
cd covscript
git checkout master
git fetch
git pull
if [[ "$#" == 1 && "$1" = "release" ]]; then
    CSPKG_CONFIG="./misc/cspkg_config.json"
    git checkout $(cat ./csbuild/release.txt)
else
    CSPKG_CONFIG="./misc/cspkg_nightly_config.json"
fi
cd ..
fetch_git covscript/ecs &
fetch_git covscript/cspkg &
fetch_git covscript/csdbc &
fetch_git covscript/stdutils &
fetch_git covscript/covanalysis &
fetch_git covscript/covscript-regex &
fetch_git covscript/covscript-codec &
fetch_git covscript/covscript-darwin &
fetch_git covscript/covscript-sqlite &
fetch_git covscript/covscript-network &
fetch_git covscript/covscript-imgui &
fetch_git covscript/covscript-process &
fetch_git covscript/covscript-curl &
fetch_git covscript/covscript-zip &
fetch_git covscript/covscript-database &
wait
start cspkg
start covscript
# Concurrent works
start ecs &
start stdutils &
start covanalysis &
start covscript-regex &
start covscript-codec &
start covscript-darwin &
start covscript-sqlite &
start covscript-network &
start covscript-imgui &
start covscript-process &
start covscript-curl &
start covscript-zip &
start covscript-database &
wait