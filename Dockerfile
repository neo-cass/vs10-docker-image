FROM  mcr.microsoft.com/windows/server:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]
RUN "mkdir C:\build"
RUN "mkdir C:\VS2010"
RUN "mkdir C:\VS2010SP1"
WORKDIR C:/build
# Download VS 2022 Build Tools installer
RUN Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile "C:\\build\\vs_buildtools.exe"; Start-Process -Wait -FilePath vs_buildtools.exe -ArgumentList '--quiet','--wait','--norestart','--nocache','--add','Microsoft.VisualStudio.Workload.VCTools','--add','Microsoft.VisualStudio.Component.VC.Tools.x86.x64','--add','Microsoft.VisualStudio.Component.VC.v143.x86.x64','--add','Microsoft.VisualStudio.Component.Windows11SDK.22621','--remove','Microsoft.VisualStudio.Component.Windows10SDK.10240','--remove','Microsoft.VisualStudio.Component.Windows10SDK.10586','--remove','Microsoft.VisualStudio.Component.Windows10SDK.14393','--remove','Microsoft.VisualStudio.Component.Windows81SDK'; Remove-Item "C:\\build\\vs_buildtools.exe" -Force

#VS2010 and SP1 installation
COPY ".\VS2010" "C:\VS2010"
COPY ".\VS2010SP1" "C:\VS2010SP1"
COPY install_vs10.ps1 "C:\build\install_vs10.ps1"
RUN ./install_vs10.ps1

# Use Chocolatey to install CMake and Git
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
RUN choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' -y
RUN choco install git -y --params '"/GitAndUnixToolsOnPath /NoAutoCrlf"'

WORKDIR C:/build
SHELL ["cmd", "/S", "/C"]
