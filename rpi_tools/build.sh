#!/bin/bash
function start ()
{
    SHELL_FOLDER=$(dirname $(readlink -f "$0"))
    cd $1
    CS_DEV_PATH=${SHELL_FOLDER}/build-cache/covscript/csdev bash $2
    cd ..
}
mkdir -p build-cache
cd build-cache
git_repo=https://github.com/covscript
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
fetch_git covscript-darwin &
fetch_git covscript-sqlite &
fetch_git covscript-network &
fetch_git covscript-streams &
fetch_git covscript-imgui &
fetch_git covscript-process &
fetch_git covscript-wiringpi &
wait
start covscript "./csbuild/make.sh"
start covscript-regex "./csbuild/make.sh" &
start covscript-codec "./csbuild/make.sh" &
start covscript-darwin "./csbuild/make.sh" &
start covscript-sqlite "./csbuild/make.sh" &
start covscript-network "./csbuild/make.sh" &
start covscript-streams "./csbuild/make.sh" &
start covscript-imgui "./csbuild/make.sh" &
start covscript-process "./csbuild/make.sh" &
start covscript-wiringpi "./csbuild/make.sh" &
wait