@echo off
REM Just1Shop Flutter Android Build Script
REM This script properly sets up the Java environment and builds the APK

REM Set JAVA_HOME to Android Studio's bundled JDK
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;C:\src\flutter\bin;%PATH%

REM Verify Java is available
echo [*] Checking Java installation...
java -version

REM Navigate to project
cd /d E:\Just1Shop

REM Clean Flutter
echo [*] Cleaning Flutter build...
call flutter clean

REM Get dependencies
echo [*] Getting dependencies...
call flutter pub get

REM Build APK
echo [*] Building Android APK (Release mode)...
call flutter build apk --release

REM Check if build was successful
if exist "build\app\outputs\apk\release\app-release.apk" (
    echo.
    echo [SUCCESS] APK built successfully!
    echo [Location] E:\Just1Shop\build\app\outputs\apk\release\app-release.apk
) else (
    echo [ERROR] APK build failed!
    exit /b 1
)

pause
