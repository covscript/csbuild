rm -rf ./build
mkdir -p build/bin
cd build-cache
cp -rf covscript/build ..
rm build/bin/cs_dbg
mv build/bin/cs build/bin/cs_safe
cp -rf covscript-regex/build ..
cp -rf covscript-codec/build ..
cp -rf covscript-network/build ..
cp -rf covscript-streams/build ..