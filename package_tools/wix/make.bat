@echo off
cd %~dp0
xcopy /Y license.rtf ..\..\build
mkdir wix_build
cd wix_build
candle ..\Product.wxs -nologo
light -ext WixUIExtension -b ..\..\..\build -cultures:en-us Product.wixobj -out CovScript.msi -nologo
xcopy /Y CovScript.msi ..\..\..
cd ..
rd /S /Q .\wix_build
del /Q ..\..\build\license.rtf