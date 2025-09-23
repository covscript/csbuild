#!/bin/bash

set -e
set -o pipefail

CURRENT_FOLDER=$(dirname "$(readlink -f "$0")")
cd "$CURRENT_FOLDER/.."

CLEANUP=false
TARGET_PATH=""
MODES=()

for arg in "$@"; do
    case "$arg" in
        release|nightly|all)
            if [ "$arg" = "all" ]; then
                MODES=("release" "nightly")
            else
                MODES=("$arg")
            fi
            ;;
        --rm)
            CLEANUP=true
            ;;
        *)
            TARGET_PATH="$arg"
            ;;
    esac
done

if [ "${#MODES[@]}" -eq 0 ] || [ -z "$TARGET_PATH" ]; then
    echo "Usage: $0 [release|nightly|all] TARGET_PATH [--rm]"
    exit 1
fi

CSBUILD_DIR="csbuild-repo"
mkdir -p "$CSBUILD_DIR"

download_files() {
    local mode=$1

    if [ "$mode" = "release" ]; then
        SOURCE_CONFIG="schedule-release"
        FILE_APPENDIX=""
        CSPKG_DIR="$TARGET_PATH/cspkg_v2/"
        PKG_DIR="$TARGET_PATH/covscript/"
    else
        SOURCE_CONFIG="schedule"
        FILE_APPENDIX="-nightly"
        CSPKG_DIR="$TARGET_PATH/cspkg_v2_nightly/"
        PKG_DIR="$TARGET_PATH/covscript/"
    fi

    local CSPKG_URLS=(
        "https://github.com/covscript/csbuild/releases/download/windows-${SOURCE_CONFIG}/cspkg-winucrt-x86_64${FILE_APPENDIX}.7z"
        "https://github.com/covscript/csbuild/releases/download/ubuntu-${SOURCE_CONFIG}/cspkg-linux-x86_64${FILE_APPENDIX}.7z"
        "https://github.com/covscript/csbuild/releases/download/ubuntu-arm-${SOURCE_CONFIG}/cspkg-linux-aarch64${FILE_APPENDIX}.7z"
        "https://github.com/covscript/csbuild/releases/download/macos-${SOURCE_CONFIG}/cspkg-macos-arm64${FILE_APPENDIX}.7z"
        "https://github.com/covscript/csbuild/releases/download/windows-${SOURCE_CONFIG}/covscript-x64${FILE_APPENDIX}.msi"
        "https://github.com/covscript/csbuild/releases/download/ubuntu-${SOURCE_CONFIG}/covscript-x86_64${FILE_APPENDIX}.deb"
        "https://github.com/covscript/csbuild/releases/download/ubuntu-arm-${SOURCE_CONFIG}/covscript-aarch64${FILE_APPENDIX}.deb"
        "https://github.com/covscript/csbuild/releases/download/macos-${SOURCE_CONFIG}/covscript-arm64${FILE_APPENDIX}.dmg"
    )

    for url in "${CSPKG_URLS[@]}"; do
        wget -c -t 10 --progress=bar:force:noscroll -P "$CSBUILD_DIR" "$url" &
    done

    wait

    rm -rf "$CSBUILD_DIR/$mode"
    mkdir -p "$CSBUILD_DIR/$mode"

    for file in "$CSBUILD_DIR"/cspkg-*${FILE_APPENDIX}.7z; do
        [[ -n "$FILE_APPENDIX" || "$file" != *-nightly.7z ]] && 7z x -aoa "$file" -o"$CSBUILD_DIR/$mode" &
    done
    wait

    rm $CSBUILD_DIR/$mode/cspkg-repo/index.json

    rsync -avzP "$CSBUILD_DIR/$mode/cspkg-repo/" "$CSPKG_DIR"

    rsync -avzP "$CSBUILD_DIR/"covscript-*${FILE_APPENDIX}.* "$PKG_DIR"
}

for mode in "${MODES[@]}"; do
    download_files "$mode" &
done

wait

if [ "$CLEANUP" = true ]; then
    rm -rf "$CSBUILD_DIR"
fi

echo "All done!"
