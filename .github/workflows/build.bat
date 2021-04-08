@echo off
cd %~dp0
set PATH=C:\Wix;C:\mingw64\bin;%PATH%
cd ..\..
call .\auto-build.bat
call .\package_tools\wix\make.bat