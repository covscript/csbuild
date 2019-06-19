#!/bin/bash
bash ../build.sh
bash ../install.sh
cp ./build-cache/covscript/examples/*.csp ./build/imports
bash ./make-app.sh ./build ./app_icon.png
bash ./make-dmg.sh ./CovScript.app ./app_bg.png
version_prefix=`./build/bin/cs -v | grep "^Version: " | awk '{print $2}'`
version_suffix=`./build/bin/cs -v | grep "^Version: " | awk '{print $NF}'`
mv covscript.dmg covscript-${version_prefix}"."${version_suffix}.dmg
rm -r CovScript.app