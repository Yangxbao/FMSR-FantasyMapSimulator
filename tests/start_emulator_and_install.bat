@echo off
rem 一键：启动 Android 模拟器 -> 安装 FMSR APK -> 启动应用 -> 截图
set SDK=C:\Users\MR\AppData\Local\Android\Sdk
set APK=E:\GameResearch\FantasyMapSimulator\build\FMSR-debug.apk
set SHOT=E:\GameResearch\FantasyMapSimulator\tests\android_screen.png

start "emulator" /wait "" "%SDK%\emulator\emulator.exe" -avd Medium_Phone_API_37.0 -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect
"%SDK%\platform-tools\adb.exe" wait-for-device
:waitboot
"%SDK%\platform-tools\adb.exe" shell getprop sys.boot_completed | findstr "1" >nul
if errorlevel 1 (timeout /t 5 >nul & goto waitboot)
"%SDK%\platform-tools\adb.exe" install -r "%APK%"
"%SDK%\platform-tools\adb.exe" shell monkey -p com.fmsr.rebuild -c android.intent.category.LAUNCHER 1
timeout /t 12 >nul
"%SDK%\platform-tools\adb.exe" exec-out screencap -p > "%SHOT%"
echo done: %SHOT%
pause
