@echo off
setlocal
title FMSR Diagnose Launch

set "GODOT=E:\Godot\Godot_v4.2.2-stable_win64_console.exe"
set "PROJ=E:\GameResearch\FantasyMapSimulator\source\fms-godot"

if not exist "%GODOT%" goto NO_GODOT

rem Kill stale instances so the new window can take focus / audio device.
taskkill /IM Godot_v4.2.2-stable_win64.exe /F >nul 2>&1
taskkill /IM Godot_v4.2.2-stable_win64_console.exe /F >nul 2>&1

echo === Launching in console mode: script errors print below ===
echo Close the game window when done; this window then shows the exit code.
echo.

"%GODOT%" --path "%PROJ%" --verbose

echo.
echo === Process exited, code %ERRORLEVEL% ===
echo If you see SCRIPT ERROR / Parse Error above, send me the last 20 lines.
pause
exit /b 0

:NO_GODOT
echo [ERROR] Godot console build not found: %GODOT%
pause
exit /b 1
