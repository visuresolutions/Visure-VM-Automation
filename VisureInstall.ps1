Invoke-WebRequest https://storage.googleapis.com/visure_downloads/Products/Visure%20Requirements/v$env:version/VisureRequirementsALMServer_$env:version.msi -Outfile c:\Temp\server.msi; \
Invoke-WebRequest https://storage.googleapis.com/visure_downloads/Products/Visure%20Requirements/v$env:version/VisureAuthoring_$env:version.msi -Outfile c:\Temp\authoring.msi; \
Start-Process -FilePath "C:\Temp\python.exe" -ArgumentList "/quiet", "PrependPath=1", "InstallAllUsers=1", "Include_launcher=1" -Wait -NoNewWindow; \
Start-Process -FilePath "C:\Temp\dotnetruntime.exe" -ArgumentList "/install", "/passive"  -NoNewWindow -Wait; \
Start-Process -FilePath "C:\Temp\vcredist2022_x64.exe" -ArgumentList "/install", "/quiet", "/norestart" -NoNewWindow -Wait; \
Start-Process msiexec -ArgumentList '/i "C:\Temp\server.msi"', '/qn', '/norestart', '/L*v "C:\Temp\install_log.txt"' -NoNewWindow -Wait; \
Start-Process -FilePath "C:\Temp\aspnetcore64.exe" -ArgumentList "/install", "/passive"  -NoNewWindow -Wait; \
Start-Process -FilePath "C:\Temp\aspnetcore86.exe" -ArgumentList "/install", "/passive"  -NoNewWindow -Wait; \
Start-Process -FilePath "C:\Temp\hosting8.exe" -ArgumentList "/install", "/quiet", "/norestart" -NoNewWindow -Wait; \
Start-Process msiexec -ArgumentList '/i "C:\Temp\msodbcsql.msi"', 'IACCEPTMSODBCSQLLICENSETERMS=YES', '/qn', '/norestart' -NoNewWindow -Wait; \
Start-Process msiexec -ArgumentList '/i "C:\Temp\psqlodbc_x64.msi"', '/qb' -NoNewWindow -Wait;
Copy-Item C:\Temp\VRSettings.json -Destination 'C:\Program Files\Visure Solutions, Inc\Visure Server 8'; \
Copy-Item C:\Temp\server.crt -Destination 'C:\Program Files\Visure Solutions, Inc\Visure Server 8'; \
Copy-Item C:\Temp\server.key -Destination 'C:\Program Files\Visure Solutions, Inc\Visure Server 8'; \
(Get-Content -Path "VRSettings.json" -Raw) -replace 'SERVER_NAME', $env:SERVER | Set-Content -Path "VRSettings.json"; \
(Get-Content -Path "VRSettings.json" -Raw) -replace 'DATABASE_NAME', $env:DATABASE | Set-Content -Path "VRSettings.json"; \
(Get-Content -Path "VRSettings.json" -Raw) -replace 'USER_NAME', $env:USER | Set-Content -Path "VRSettings.json"; \
$VariableName = .\VisureToken.exe $($env:PASSW); \
$VariableName2= ($VariableName -split '\\n' | Select-Object -Skip 16) -join '\\n'; \
(Get-Content -Path "VRSettings.json" -Raw) -replace 'PASSWORD_NAME', $VariableName2 | Set-Content -Path "VRSettings.json"; \
$VariableName3 = .\VisureToken.exe $($env:APASSW); \
$VariableName4= ($VariableName3 -split '\\n' | Select-Object -Skip 16) -join '\\n'; \
(Get-Content -Path "VRSettings.json" -Raw) -replace 'ADMIN_PASSWORD', $VariableName4 | Set-Content -Path "VRSettings.json"; \
Install-WindowsFeature -name Web-Server -IncludeManagementTools;
$thumbprint = 'D9158BACC1BD91AFEDF585EB02703AAAD59C88AC'; \
New-WebBinding -Name 'Default Web Site' -Protocol https -Port 443 -SslFlags 0; \
$binding = Get-WebBinding -Name 'Default Web Site' -Protocol https; \
if ($null -eq $binding) { Write-Host "Binding not found"; exit 1 }; \
$cert = Get-ChildItem -Path cert:\LocalMachine\My\$thumbprint; \
if ($null -eq $cert) { Write-Host "Certificate not found"; exit 1 }; \
$hash = $cert.GetCertHashString(); \
$store = 'my'; \
$binding.AddSslCertificate($hash, $store);
Set-Location 'C:\inetpub\Visure Authoring 8'; \
(Get-Content -Path "appsettings.json" -Raw) -replace 'container', $env:DATABASE | Set-Content -Path "appsettings.json"; \
Set-Location 'C:\inetpub\Visure Authoring 8\wwwroot\assets'; \
(Get-Content -Path "settings.json" -Raw) -replace 'container', $env:DATABASE | Set-Content -Path "settings.json"; \
Copy-Item C:\Temp\visurecloud.com.crt -Destination 'C:\inetpub\Visure Authoring 8\Certificates'; \
IISRESET; \
Set-Location 'C:\Temp'; \
Remove-Item -Recurse -Path '*';