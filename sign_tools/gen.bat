@echo off
md cert
cd bin
gen ..\cert\covscript covscript.org
cd ..
echo on