$ErrorActionPreference = 'Stop'

Write-Host "Launching Pixel 9 emulator..."
flutter emulators --launch Pixel_9 | Out-Null

# Wait for emulator device to be detected
$timeoutSec = 120
$elapsed = 0
$deviceId = $null
while ($elapsed -lt $timeoutSec) {
  $devices = flutter devices | Out-String
  # Prefer a device whose name contains Pixel 9; else any emulator-xxxx
  if ($devices -match '^(?s).*emulator-\d+.*$') {
    # Try to extract the line that has Pixel 9 first
    $lines = $devices -split "`n"
    $pixelLine = $lines | Where-Object { $_ -match 'Pixel 9' -and $_ -match 'emulator-\d+' } | Select-Object -First 1
    if ($pixelLine) {
      if ($pixelLine -match 'emulator-\d+') { $deviceId = $Matches[0] }
    }
    if (-not $deviceId) {
      $firstEmuLine = $lines | Where-Object { $_ -match 'emulator-\d+' } | Select-Object -First 1
      if ($firstEmuLine -and ($firstEmuLine -match 'emulator-\d+')) { $deviceId = $Matches[0] }
    }
  }
  if ($deviceId) { break }
  Start-Sleep -Seconds 2
  $elapsed += 2
}

if (-not $deviceId) {
  Write-Error "No emulator device became available within $timeoutSec seconds."
  exit 1
}

Write-Host "Using device: $deviceId"
flutter run -d $deviceId


