@echo off
cd %~dp0
set PATH=C:\Wix;C:\mingw64\bin;%PATH%
cd ..\..
call .\auto-build.bat release
call .\package_tools\wix\make.bat