

# Disable Program Compatibility Assistant to avoid VS2010 install hanging indefinitely due to popups
Write-Host "Disabling Program Compatibility Assistant"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant' -Name "DisablePCA" -Value 1 -Type DWord
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisablePCA" -Value 1 -Type DWord
Write-Host "Enabling .NET 3.5"
dism.exe /online /enable-feature /featurename:NetFx3 /All
Write-Host "Enabling .NET 4.0"
dism.exe /online /enable-feature /featurename:NetFx4 /All
cd C:/VS2010/Setup
Write-Host "Installing Visual Studio 2010"
Start-Process -FilePath ./setup.exe -ArgumentList '/q /norestart /full' -Wait
cd C:/VS2010SP1
Write-Host "Installing Visual Studio 2010 SP1"
Start-Process -FilePath ./Setup.exe -ArgumentList '/q /norestart /log install.log' -Wait