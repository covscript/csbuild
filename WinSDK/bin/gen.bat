@makecert.exe -sv %1.pvk -r -n "CN=%2" %1.cer
@cert2spc.exe %1.cer %1.spc
@pvk2pfx.exe -pvk %1.pvk -spc %1.spc -pfx %1.pfx -f