@echo off
cd %~dp0
md cert
cd bin
gen ..\cert\covscript covscript.org
cd ..