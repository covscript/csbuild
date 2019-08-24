@echo off
cd builds
del *.7z
7z a -mmt4 -mx9 build.7z build
7z a -mmt4 -mx9 build_x64.7z build_x64
7z a -mmt4 -mx9 cs_dev.7z build\include build\lib
rd /S /Q build\include build\lib
7z a -mmt4 -mx9 cs_dev_x64.7z build_x64\include build_x64\lib
rd /S /Q build_x64\include build_x64\lib