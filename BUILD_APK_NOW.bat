@echo off
REM ==========================================
REM PHANUKNGAN — Build APK (Windows)
REM ==========================================
REM ວິທີໃຊ້:
REM   1. ເປີດ CMD ໃນ Folder phanukngan
REM   2. Double-click BUILD_APK_NOW.bat
REM ==========================================

echo.
echo ============================================
echo   PHANUKNGAN - Build APK
echo ============================================
echo.

REM ---- ກວດ Flutter ----
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter ບໍ່ພົບ!
    echo ໄປ flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)
echo [OK] Flutter ພ້ອມ

REM ---- flutter pub get ----
echo.
echo [1/4] flutter pub get...
call flutter pub get
if %errorlevel% neq 0 ( echo [ERROR] pub get ລົ້ມ & pause & exit /b 1 )
echo [OK] Dependencies ໂຫລດແລ້ວ

REM ---- Clean ----
echo.
echo [2/4] flutter clean...
call flutter clean
call flutter pub get

REM ---- Build DEBUG APK (ບໍ່ຕ້ອງ Keystore) ----
echo.
echo [3/4] Build APK (Debug - ໃຊ້ Test ໄດ້ທັນທີ)...
call flutter build apk --debug

if %errorlevel% neq 0 (
    echo [ERROR] Build ລົ້ມ - ກວດ Error ຂ້າງເທິງ
    pause
    exit /b 1
)

echo.
echo [4/4] ສ'ເລ'ດ!
echo.
echo ============================================
echo   APK ຢູ່ທ'ນ'':
echo   build\app\outputs\flutter-apk\app-debug.apk
echo ============================================
echo.
echo ວິທີຕິດຕ'ງ:
echo   1. ສ'ງ APK ໄປໂທລະສ'ບ (USB / Google Drive)
echo   2. ເປີດໄຟລ' .apk ໃນໂທລະສ'ບ
echo   3. Allow Unknown Sources → Install
echo.
pause
