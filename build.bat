@echo off
mkdir build-cache
cd build-cache
call:git_fetch cspkg
call:git_fetch covscript
call:git_fetch covscript-regex
call:git_fetch covscript-codec
call:git_fetch covscript-darwin
call:git_fetch covscript-sqlite
call:git_fetch covscript-network
call:git_fetch covscript-streams
call:git_fetch covscript-imgui
call:git_fetch covscript-process
call:git_fetch covscript-curl
call:git_fetch covscript-zip
call:git_fetch covscript-database
start /WAIT /D covscript csbuild\make.bat
set CS_DEV_PATH=%cd%\covscript\csdev
start /D covscript-regex csbuild\make.bat
start /D covscript-codec csbuild\make.bat
start /D covscript-darwin csbuild\make.bat
start /D covscript-sqlite csbuild\make.bat
start /D covscript-network csbuild\make.bat
start /D covscript-streams csbuild\make.bat
start /D covscript-imgui csbuild\make.bat
start /D covscript-process csbuild\make.bat
start /D covscript-curl csbuild\make.bat
start /D covscript-zip csbuild\make.bat
start /D covscript-database csbuild\make.bat
goto:eof
:git_fetch
if exist %1% (
    cd %1%
    git fetch
    git pull
    git clean -dfx
    cd ..
) else (
    git clone https://hub.fastgit.org/covscript/%1% --depth=1
)
goto:eof