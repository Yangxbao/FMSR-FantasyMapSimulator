@echo off
setlocal
title FMSR Launcher

set "GODOT=E:\Godot\Godot_v4.2.2-stable_win64.exe"
set "PROJ=E:\GameResearch\FantasyMapSimulator\source\fms-godot"

if not exist "%GODOT%" goto NO_GODOT
if not exist "%PROJ%\project.godot" goto NO_PROJ

rem Kill stale instances left by an abnormal exit or by an automated
rem screenshot run (-- seed=N shot=S). A zombie instance can steal focus
rem and make a fresh launch look like "nothing happens".
taskkill /IM Godot_v4.2.2-stable_win64.exe /F >nul 2>&1
taskkill /IM Godot_v4.2.2-stable_win64_console.exe /F >nul 2>&1

echo Starting FMSR rebuild ... please wait about 5 seconds.
start "" "%GODOT%" --path "%PROJ%"

timeout /t 12 /nobreak >nul
tasklist /FI "IMAGENAME eq Godot_v4.2.2-stable_win64.exe" | findstr /I "Godot_v4.2.2-stable_win64.exe" >nul
if errorlevel 1 goto LAUNCH_FAIL

echo.
echo OK - game is running. Window title should be: FMSR - Fantasy Map Rebuild
timeout /t 3 /nobreak >nul
exit /b 0

:NO_GODOT
echo [ERROR] Godot engine not found: %GODOT%
pause
exit /b 1

:NO_PROJ
echo [ERROR] Project not found: %PROJ%\project.godot
pause
exit /b 1

:LAUNCH_FAIL
echo.
echo [WARN] Process exited right after launch - startup failed.
echo        Run launcher-diagnose.bat to see the actual error text.
pause
exit /b 1
