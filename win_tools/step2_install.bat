@echo off
rd /S /Q builds
start /D x86 /WAIT install.bat
start /D x64 /WAIT install.bat
xcopy /E /Y x86\build builds\build\
xcopy /E /Y x64\build builds\build_x64\