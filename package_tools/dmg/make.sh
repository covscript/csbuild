#!/bin/bash
bash ./package_tools/dmg/make-app.sh ./build ./package_tools/dmg/app_icon.png
bash ./package_tools/dmg/make-dmg.sh ./CovScript.app ./package_tools/dmg/app_bg.png "$1"
version_prefix=`./build/bin/cs -v | grep "^Version: " | awk '{print $2}'`
version_suffix=`./build/bin/cs -v | grep "^Version: " | awk '{print $NF}'`
mv covscript.dmg covscript-${version_prefix}"."${version_suffix}.dmg
rm -r CovScript.app