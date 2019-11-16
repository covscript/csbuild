rm -rf ./build
mkdir -p build/bin
cd build-cache
cp -rf covscript/build ..
cp -rf covscript-regex/build ..
cp -rf covscript-codec/build ..
cp -rf covscript-network/build ..
cp -rf covscript-streams/build ..
cd ..
rm build/bin/cs_dbg
rm -rf build/lib