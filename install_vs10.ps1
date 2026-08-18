

# Container OS revision. The host revision is printed by the workflow;
# CBS servicing is sensitive to skew between the two.
Write-Host "Container UBR: $((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR)"
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
        # dism.log only shows the eventual timeout, not what CBS was doing during
        # the silent Internal_Finalize hang. cbs.log is far more verbose and is
        # where that gap should actually show up.
        Write-Host "--- CBS.log (tail) ---"
        Get-Content C:\Windows\Logs\CBS\CBS.log -Tail 200 -ErrorAction SilentlyContinue
        throw "DISM failed to enable $Feature (exit code $LASTEXITCODE)."
    }
}
Write-Host "Enabling .NET 3.5"
# Both DISM verbs (/Enable-Feature and /Add-Capability) route NetFx3 through the
# same Windows-Update-backed FOD acquirer, which stalls indefinitely on this
# runner (confirmed via CBS.log: FCAcquirerWUClient download never progresses
# past 0 bytes, regardless of verb). The standalone .NET Framework 3.5 SP1
# redistributable predates the Feature-on-Demand model and is a self-contained
# installer, not a DISM wrapper, so it doesn't touch WU at all.
Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/b635098a-2d1d-4142-bef6-d237545123cb/2651b87007440a15209cac29634a4e45/dotnetfx35.exe" -OutFile "C:\build\dotnetfx35.exe"
$proc = Start-Process -FilePath "C:\build\dotnetfx35.exe" -ArgumentList '/q', '/norestart' -Wait -PassThru
Remove-Item "C:\build\dotnetfx35.exe" -Force
if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) {
    # This bootstrapper logs to %TEMP%\dd_dotnetfx35*.txt, not the DISM log paths.
    Write-Host "--- dotnetfx35 logs ---"
    Get-ChildItem "$env:TEMP\dd_dotnetfx35*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "--- $($_.Name) ---"
        Get-Content $_.FullName -ErrorAction SilentlyContinue
    }
    throw "dotnetfx35.exe failed to install .NET 3.5 (exit code $($proc.ExitCode))."
}
Write-Host "Enabling .NET 4.0"
dism.exe /online /enable-feature /featurename:NetFx4 /All
Assert-Dism "NetFx4"
cd C:/VS2010/Setup
Write-Host "Installing Visual Studio 2010"
Start-Process -FilePath ./setup.exe -ArgumentList '/q /norestart /full' -Wait
cd C:/VS2010SP1
Write-Host "Installing Visual Studio 2010 SP1"
Start-Process -FilePath ./Setup.exe -ArgumentList '/q /norestart /log install.log' -Wait