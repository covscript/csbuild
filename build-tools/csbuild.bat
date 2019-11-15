@echo off
set ARGS="%~dp0\csbuild"
:LOOP
    set index=%1
    if %index%! == ! goto END
    set ARGS=%ARGS% %index%
    shift
    goto LOOP
:END
cs %ARGS%