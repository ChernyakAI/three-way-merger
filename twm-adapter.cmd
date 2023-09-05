@ECHO OFF
SETLOCAL

SET command="c:/Program Files/OneScript/bin/oscript.exe"
SET arg="%~dp0src/main.os"

@REM --merge %baseCfg %secondCfg %oldVendorCfg %merged

if /%1/==/--merge/ (
    echo f | xcopy /f /y %2 "%~2.bsl"
    echo f | xcopy /f /y %3 "%~3.bsl"
    echo f | xcopy /f /y %4 "%~4.bsl"
    echo f | xcopy /f /y %3 "%~5.bsl"
    %command% %arg% M --old "%~4.bsl" --base "%~2.bsl" --new "%~3.bsl" --result "%~5.bsl" --mode "priority_new"
    echo f | xcopy /f /y "%~5.bsl" %5
)
