#!/bin/bash
CURRENT_FOLDER=$(dirname $(readlink -f "$0"))
cd $CURRENT_FOLDER/..
if [[ "$#" = 2 && "$1" = "release" ]]; then
    echo "Sync for release..."
    SOURCE_CONFIG="schedule-release"
    FILE_APPENDIX=""
    PKG_SFTP_TARGET="$2/covscript/"
    CSPKG_SFTP_TARGET="$2/cspkg/"
elif [[ "$#" = 1 ]]; then
    echo "Sync for nightly..."
    SOURCE_CONFIG="schedule"
    FILE_APPENDIX="-nightly"
    PKG_SFTP_TARGET="$1/covscript/"
    CSPKG_SFTP_TARGET="$1/cspkg_nightly/"
else
    echo "Usage: sync_source.sh [release] TARGET_PATH"
    exit
fi
wget -t 10 "https://github.com/covscript/csbuild/releases/download/windows-${SOURCE_CONFIG}/cspkg-winucrt-x86_64${FILE_APPENDIX}.7z" &
wget -t 10 "https://github.com/covscript/csbuild/releases/download/ubuntu-${SOURCE_CONFIG}/cspkg-linux-x86_64${FILE_APPENDIX}.7z" &
wget -t 10 "https://github.com/covscript/csbuild/releases/download/macos-${SOURCE_CONFIG}/cspkg-macos-arm64${FILE_APPENDIX}.7z" &
wait
7z x -aoa "cspkg-winucrt-x86_64${FILE_APPENDIX}.7z" &
7z x -aoa "cspkg-linux-x86_64${FILE_APPENDIX}.7z" &
7z x -aoa "cspkg-macos-arm64${FILE_APPENDIX}.7z" &
wait
rm "cspkg-winucrt-x86_64${FILE_APPENDIX}.7z" "cspkg-linux-x86_64${FILE_APPENDIX}.7z" "cspkg-macos-arm64${FILE_APPENDIX}.7z"
rsync -avzP ./cspkg-repo/* $CSPKG_SFTP_TARGET
rm -rf ./cspkg-repo
wget -t 10 -P covscript-repo https://github.com/covscript/csbuild/releases/download/windows-${SOURCE_CONFIG}/covscript-x64${FILE_APPENDIX}.msi &
wget -t 10 -P covscript-repo https://github.com/covscript/csbuild/releases/download/ubuntu-${SOURCE_CONFIG}/covscript-amd64${FILE_APPENDIX}.deb &
wget -t 10 -P covscript-repo https://github.com/covscript/csbuild/releases/download/macos-${SOURCE_CONFIG}/covscript-arm64${FILE_APPENDIX}.dmg &
wait
rsync -avzP ./covscript-repo/* $PKG_SFTP_TARGET
rm -rf ./covscript-repo