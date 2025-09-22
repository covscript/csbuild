@echo off
cd %~dp0
xcopy /Y icon.ico ..\..\build
xcopy /Y license.rtf ..\..\build
for /F %%i in ('..\..\build\bin\cs -i ..\..\build\imports .\get_csver.csc') do set CSVER=%%i
for /F %%i in ('..\..\build\bin\cs -i ..\..\build\imports .\candle_args.csc') do set CANDLE_ARGS=%%i
echo CovScript Runtime Version: %CSVER%
..\..\build\bin\cs -i ..\..\build\imports .\gen_wxs.csc .\wxs_template.xml
mkdir wix_build
cd wix_build
candle %CANDLE_ARGS% ..\Product.wxs -nologo
light -ext WixUIExtension -b ..\..\..\build -cultures:en-us Product.wixobj -out covscript-%CSVER%.msi -nologo
xcopy /Y covscript-%CSVER%.msi ..\..\..
cd ..
rd /S /Q .\wix_build
del /Q .\Product.wxs
cd ..\..
del /Q .\build\icon.ico
del /Q .\build\license.rtf
if exist misc\cert (
    cd misc\bin
    sign.bat ..\cert\covscript ..\..\*.msi
)