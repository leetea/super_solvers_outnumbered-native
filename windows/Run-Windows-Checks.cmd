@echo off
setlocal
set "OUTNUMBERED_CHECK_OUTPUT=%LOCALAPPDATA%\OutnumberedNativeReimplementation\Verification-%RANDOM%-%RANDOM%"
mkdir "%OUTNUMBERED_CHECK_OUTPUT%"
"%~dp0Outnumbered.exe" --self-test > "%OUTNUMBERED_CHECK_OUTPUT%\checks.json" 2> "%OUTNUMBERED_CHECK_OUTPUT%\errors.txt"
set "CHECK_RESULT=%ERRORLEVEL%"
echo Verification exit code: %CHECK_RESULT%
echo Results: "%OUTNUMBERED_CHECK_OUTPUT%"
echo Your regular player profiles were not used for these checks.
pause
exit /b %CHECK_RESULT%
