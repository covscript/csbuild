@echo off
cd %~dp0
set PATH="C:\wix;C:\mingw-w64\bin;%PATH%"
echo %PATH%
cd ..\..\
.\auto-build.bat
.\package_tools\dmg\make.bat