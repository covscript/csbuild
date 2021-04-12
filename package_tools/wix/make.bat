@echo off
cd %~dp0
xcopy /Y icon.ico ..\..\build
xcopy /Y license.rtf ..\..\build
for /F %%i in ('..\..\build\bin\cs -i ..\..\build\imports .\get_csver.csc') do (set csver=%%i)
echo CovScript Runtime Version: %csver%
..\..\build\bin\cs -i ..\..\build\imports .\gen_wxs.csc .\wxs_template.xml
mkdir wix_build
cd wix_build
candle ..\Product.wxs -nologo
light -ext WixUIExtension -b ..\..\..\build -cultures:en-us Product.wixobj -out covscript-%csver%.msi -nologo
xcopy /Y covscript-%csver%.msi ..\..\..
cd ..
rd /S /Q .\wix_build
del /Q .\Product.wxs
cd ..\..
del /Q .\build\icon.ico
del /Q .\build\license.rtf
cd misc\bin
sign.bat ..\cert\covscript ..\..\*.msi