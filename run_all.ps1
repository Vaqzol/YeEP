# Run all services in separate PowerShell windows
# Usage: right-click -> Run with PowerShell, or from an elevated PowerShell: .\run_all.ps1

# --- gps-simple ---
$gpsDir = "$env:USERPROFILE\Downloads\YeEP\YeEP\gps-simple"
$gpsCmd = @'
cd "' + $gpsDir + '"
if (!(Test-Path -Path out)) { New-Item -ItemType Directory -Path out | Out-Null }
$files = Get-ChildItem -Path src -Filter *.java -Recurse | ForEach-Object -ExpandProperty FullName
if ($files) { javac -d out $files }
java -cp out Main
'@
Start-Process powershell -ArgumentList '-NoExit','-Command',$gpsCmd

# --- Yeep backend (Spring Boot) ---
$backendDir = "c:\Proj\proj6393\yeep_backend"
$backendCmd = @'
cd "' + $backendDir + '"
if (Test-Path .\mvnw.cmd) { .\mvnw.cmd spring-boot:run } else { mvn spring-boot:run }
'@
Start-Process powershell -ArgumentList '-NoExit','-Command',$backendCmd

# --- Flutter app ---
$flutterDir = "c:\Proj\proj6393\yeep_app"
$flutterCmd = @'
cd "' + $flutterDir + '"
flutter pub get
flutter run
'@
Start-Process powershell -ArgumentList '-NoExit','-Command',$flutterCmd

Write-Host "Launched gps-simple, Yeep backend, and Flutter app in separate windows."