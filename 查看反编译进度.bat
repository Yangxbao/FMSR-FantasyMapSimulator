@echo off
rem ASCII only! Do NOT type Chinese here (cmd reads .bat as GBK).
rem Chinese output comes from the Python script, which is UTF-8.
chcp 65001 >nul
cd /d "%~dp0"
python tools\decompile_status.py
if errorlevel 1 (
  echo.
  echo python not found, trying py launcher...
  py tools\decompile_status.py
)
echo.
pause
