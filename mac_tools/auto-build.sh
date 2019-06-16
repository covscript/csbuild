#!/bin/bash
bash ../build.sh
bash ../install.sh
bash ./make-app.sh ./build ./app_icon.png
bash ./make-dmg.sh ./CovScript.app
version_prefix=`./build/bin/cs -v | grep "^Version: " | awk '{print $2}'`
version_suffix=`./build/bin/cs -v | grep "^Version: " | awk '{print $NF}'`
mv covscript.dmg covscript-${version_prefix}"."${version_suffix}.dmg
rm -r CovScript.app