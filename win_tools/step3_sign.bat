@echo off
start /D ..\sign_tools\bin sign.bat ..\cert\covscript ..\..\win_tools\builds\*.exe
::start /D ..\sign_tools\bin sign.bat ..\cert\covscript ..\..\win_tools\builds\build\bin\*.exe
start /D ..\sign_tools\bin sign.bat ..\cert\covscript ..\..\win_tools\builds\build_x64\bin\*.exe