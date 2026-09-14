# Shared safety and stability functions for Windows 10 Debloater scripts.

Function Check-OSVersion {
    Write-Host "Checking OS Version..."
    $OS = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    If ($OS.Caption -notmatch "Windows 10" -and $OS.Caption -notmatch "Windows 11") {
        Write-Warning "This script is designed for Windows 10 and Windows 11. Running it on other versions (like $($OS.Caption)) may cause instability."
        $Prompt = Read-Host "Do you want to continue anyway? (Y/N)"
        If ($Prompt -notmatch '^(?i:y|yes)$') {
            throw "Unsupported OS version. Exiting for safety."
        }
    }
    Write-Host "OS Version: $($OS.Caption) - Check passed."
}

Function Enable-SystemProtection {
    $Drive = "$env:SystemDrive\"
    $Answer = Read-Host "Enable System Protection on $Drive before creating a restore point? (Y/N)"
    If ($Answer -match '^(?i:y|yes)$') {
        Enable-ComputerRestore -Drive $Drive -ErrorAction Stop
    }
}

Function Create-RestorePoint {
    Param(
        [string]$Description = "Before Windows 10 Debloat"
    )
    
    Write-Host "Attempting to create a System Restore Point: '$Description'..."
    Write-Host "This may take a minute. Please wait..."
    
    Try {
        $Before = @(Get-ComputerRestorePoint -ErrorAction Stop)
        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        $After = @(Get-ComputerRestorePoint -ErrorAction Stop)
        $NewPoint = $After | Where-Object {
            $_.SequenceNumber -notin $Before.SequenceNumber -and $_.Description -eq $Description
        }
        If (!$NewPoint) { throw 'Windows did not create a new restore point (creation may be throttled).' }
        Write-Host "Successfully created Restore Point: '$Description'."
    } Catch {
        Write-Warning "Failed to create Restore Point. Error: $($_.Exception.Message)"
        Write-Warning "Proceeding without a restore point. Ensure you have a full system backup before continuing."
        $Continue = Read-Host "Do you wish to proceed anyway? (Y/N)"
        If ($Continue -notmatch '^(?i:y|yes)$') {
            throw "User cancelled due to missing restore point."
        }
    }
}

Function Run-SafetyChecks {
    Param([string]$Description = 'Before Windows 10 Debloat')
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
        throw 'Run this script from Windows PowerShell as Administrator.'
    }
    Check-OSVersion
    Enable-SystemProtection
    Create-RestorePoint -Description $Description
}

Function Log-Error {
    Param(
        [string]$Message,
        [string]$Source = "Unknown"
    )
    
    $LogFolder = "C:\Temp\Windows10Debloater"
    If (!(Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    }
    
    $LogFile = Join-Path $LogFolder "errors.log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp][$Source] ERROR: $Message"
    
    Add-Content -Path $LogFile -Value $LogEntry
}

# Keep user data and sync configuration intact; the installer owns application cleanup.
Function UninstallOneDrive {
    $Candidates = @(
        "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
        "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
        "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDriveSetup.exe"
    )
    $Installer = $Candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    If (!$Installer) { throw 'OneDrive installer not found. Uninstall OneDrive through Windows Settings.' }

    Write-Host 'Uninstalling OneDrive. Local sync folders are preserved; online-only files are not downloaded.'
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    $Process = Start-Process -FilePath $Installer -ArgumentList '/uninstall' -Wait -PassThru -ErrorAction Stop
    If ($Process.ExitCode -ne 0) { throw "OneDrive uninstall failed with exit code $($Process.ExitCode)." }
    Write-Host 'OneDrive uninstaller completed. User files and folders have been preserved.'
}
