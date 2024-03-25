$url = "https://www.cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
$outputPath = [System.IO.Path]::Combine($env:PUBLIC, "Downloads\CloudbaseInitSetup_Stable_x64.msi")

# Download the file
Invoke-WebRequest -Uri $url -OutFile $outputPath

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$outputPath`" /qn /l*v log.txt" -Wait