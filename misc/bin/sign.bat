@signtool sign /fd SHA256 /f %1.pfx %2
@signtool timestamp /t http://timestamp.digicert.com/ %2