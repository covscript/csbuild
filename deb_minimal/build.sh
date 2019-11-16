#!/bin/bash
function start ()
{
    SHELL_FOLDER=$(dirname $(readlink -f "$0"))
    cd $1
    CS_DEV_PATH=${SHELL_FOLDER}/covscript/csdev bash $2
    cd ..
}
mkdir -p build-cache
cd build-cache
git_repo=https://github.com/covscript
function fetch_git ()
{
    if [ ! -d "$1" ]; then
        git clone $git_repo/$1 --depth=1 -b $2
    else
        cd $1
        git fetch
        git pull
        git clean -dfx
        cd ..
    fi
}
fetch_git covscript sandbox &
fetch_git covscript-regex master &
fetch_git covscript-codec master &
fetch_git covscript-network master &
fetch_git covscript-streams master &
wait
start covscript "./csbuild/make.sh"
start covscript-regex "./csbuild/make.sh" &
start covscript-codec "./csbuild/make.sh" &
start covscript-network "./csbuild/make.sh" &
start covscript-streams "./csbuild/make.sh" &
wait