@echo off
cd %~dp0
candle Product.wxs
light -ext WixUIExtension -cultures:en-us Product.wixobj -out CovScript.msi