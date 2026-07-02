#!/bin/bash

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
CURRENT_FOLDER="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"
export CS_DEV_PATH="$CURRENT_FOLDER/build-cache/covscript/csdev"
cd "$CURRENT_FOLDER"

if [[ "$#" = 1 && "$1" = "release" ]]; then
    echo "Building for release..."
    CSPKG_CONFIG="./misc/cspkg_config.json"
else
    echo "Building for nightly..."
    CSPKG_CONFIG="./misc/cspkg_nightly_config.json"
fi

if [[ "$#" -gt 0 ]]; then
    bash ./misc/unix_build_minimal.sh "$1"
else
    bash ./misc/unix_build_minimal.sh
fi

rm -rf ./build
mkdir -p build/bin
cd build-cache

# Setup basic environment

cp -rf covscript/build ..
cp -rf covscript/csdev/* ../build/
cp -rf covscript-regex/build ..
cp -rf covscript-codec/build ..
cp -rf covscript-process/build ..

cd ..

./build/bin/cs -i ./build/imports ./misc/parallel_build.csc ./misc/parallel_config.json
./build/bin/cs -i ./build/imports ./misc/cspkg_collect.csc "$CSPKG_CONFIG"
cp -rf build-cache/ecs/build .
cp -rf build-cache/cspkg/build .
cp -rf build-cache/covscript-curl/build .
if [[ "$#" != 1 || "$1" != "release" ]]; then
    ./build/bin/cs -i ./build/imports ./misc/replace_source.csc ./build/bin/cspkg
fi
chmod +x ./build/bin/ecs
