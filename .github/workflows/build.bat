@echo off
cd %~dp0
7z x ..\..\gcc-10.2.0-mingw-w64-8.0.0-r8-covscript.org.zip
7z x ..\..\wix311-binaries.zip -owix
setx /M Path "%cd%\wix;%cd%\mingw-w64\bin;%PATH%"
echo %PATH%
cd ..\..\
.\auto-build.bat
.\package_tools\dmg\make.bat