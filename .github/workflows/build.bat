@echo off
cd %~dp0
set PATH=C:\Wix;C:\mingw64\bin;%PATH%
echo %PATH%
cd ..\..\
.\auto-build.bat
.\package_tools\wix\make.bat