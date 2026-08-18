

# Disable Program Compatibility Assistant to avoid VS2010 install hanging indefinitely due to popups
Write-Host "Disabling Program Compatibility Assistant"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant' -Name "DisablePCA" -Value 1 -Type DWord
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisablePCA" -Value 1 -Type DWord
# PowerShell 5.1 ignores native exit codes, so DISM failures are silent unless
# checked explicitly. 3010 is ERROR_SUCCESS_REBOOT_REQUIRED, not a failure.
function Assert-Dism([string]$Feature) {
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 3010) {
        # The failed layer's container is discarded, so dump the log inline;
        # it is only ever visible in the build output.
        Write-Host "--- dism.log (errors) ---"
        Select-String -Path C:\Windows\Logs\DISM\dism.log -Pattern 'Error|Failed' -ErrorAction SilentlyContinue | Select-Object -Last 40
        Write-Host "--- dism.log (tail) ---"
        Get-Content C:\Windows\Logs\DISM\dism.log -Tail 60 -ErrorAction SilentlyContinue
        throw "DISM failed to enable $Feature (exit code $LASTEXITCODE)."
    }
}
Write-Host "Enabling .NET 3.5"
dism.exe /online /enable-feature /featurename:NetFx3 /All
Assert-Dism "NetFx3"
Write-Host "Enabling .NET 4.0"
dism.exe /online /enable-feature /featurename:NetFx4 /All
Assert-Dism "NetFx4"
cd C:/VS2010/Setup
Write-Host "Installing Visual Studio 2010"
Start-Process -FilePath ./setup.exe -ArgumentList '/q /norestart /full' -Wait
cd C:/VS2010SP1
Write-Host "Installing Visual Studio 2010 SP1"
Start-Process -FilePath ./Setup.exe -ArgumentList '/q /norestart /log install.log' -Wait