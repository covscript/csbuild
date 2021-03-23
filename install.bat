@echo off
rd /S /Q .\build
mkdir build
xcopy /Y ..\..\build-tools\csbuild build\bin\
xcopy /Y ..\..\build-tools\csbuild.bat build\bin\
cd build-cache
xcopy /Y cspkg\cspkg ..\build\bin\
xcopy /Y cspkg\cspkg.bat ..\build\bin\
xcopy /E /Y covscript\build ..\build\
xcopy /E /Y covscript\csdev ..\build\
xcopy /E /Y covscript-regex\build ..\build\
xcopy /E /Y covscript-codec\build ..\build\
xcopy /E /Y covscript-darwin\build ..\build\
xcopy /E /Y covscript-sqlite\build ..\build\
xcopy /E /Y covscript-network\build ..\build\
xcopy /E /Y covscript-imgui\build ..\build\
xcopy /E /Y covscript-process\build ..\build\
xcopy /E /Y covscript-curl\build ..\build\
xcopy /E /Y covscript-zip\build ..\build\
xcopy /E /Y covscript-database\build ..\build\