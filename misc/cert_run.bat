@echo off
cd %~dp0
cd bin
sign ..\cert\covscript ..\*.exe
cd ..