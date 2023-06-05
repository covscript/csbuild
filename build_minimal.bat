@echo off
mkdir build-cache
cd %~dp0\build-cache

set GIT_REPO="https://github.com/covscript/"

call:git_clone covscript
cd covscript
git checkout master
git fetch
git pull
if "%1%" EQU "release" (
    echo Building for release...
    set CSPKG_CONFIG=".\misc\cspkg_config.json"
    for /f "delims=" %%x in (.\csbuild\release.txt) do git checkout %%x
) else (
    echo Building for nightly...
    set CSPKG_CONFIG=".\misc\cspkg_nightly_config.json"
)
cd ..

call:git_fetch cspkg
call:git_fetch covscript-regex
call:git_fetch covscript-codec
call:git_fetch covscript-process

call:call_bat cspkg
call:call_bat covscript
set CS_DEV_PATH=%cd%\covscript\csdev
call:call_bat covscript-regex
call:call_bat covscript-codec
call:call_bat covscript-process

cd ..
rd /S /Q .\build
mkdir build
cd build-cache

xcopy /E /Y cspkg\build ..\build\
xcopy /E /Y covscript\build ..\build\
xcopy /E /Y covscript\csdev ..\build\
xcopy /E /Y covscript-regex\build ..\build\
xcopy /E /Y covscript-codec\build ..\build\
xcopy /E /Y covscript-process\build ..\build\

cd ..\misc\bin
call sign.bat ..\cert\covscript ..\..\build\bin\*.exe
cd ..\..

.\build\bin\cs -i .\build\imports .\misc\win32_build.csc .\misc\win32_config_minimal.json
if "%1%" NEQ "release" (
    .\build\bin\cs -i .\build\imports .\misc\replace_source.csc .\build\bin\cspkg
)

cd build-cache
xcopy /E /Y covscript-curl\build ..\build\
xcopy /E /Y ecs\build\ ..\build\
cd ..

goto:eof
:call_bat
cd %1%
call csbuild\make.bat
cd ..
goto:eof
:git_clone
if not exist %1% (
    git clone %GIT_REPO%/%1%
)
goto:eof
:git_fetch
if exist %1% (
    cd %1%
    git fetch
    git pull
    cd ..
) else (
    git clone %GIT_REPO%/%1% --depth=1
)
goto:eof