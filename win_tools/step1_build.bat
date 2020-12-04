@echo off
::mkdir x86
::xcopy /Y ..\build.bat x86\
::xcopy /Y ..\install.bat x86\
::set PATH_OLD=%PATH%
::set PATH=%PATH_OLD%;%cd%\mingw32\bin
::start /D x86 build.bat
::gcc --version
mkdir x64
xcopy /Y ..\build.bat x64\
xcopy /Y ..\install.bat x64\
::set PATH=%PATH_OLD%;%cd%\mingw64\bin
start /D x64 build.bat
gcc --version
pause