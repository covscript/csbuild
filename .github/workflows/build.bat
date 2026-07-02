@echo off
cd %~dp0
set PATH=C:\msys64\ucrt64\bin;C:\Program Files (x86)\WiX Toolset v3.11\bin;%PATH%
cd ..\..
call .\auto-build.bat %1
call .\package_tools\wix\make.bat