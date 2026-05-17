param(
  [Parameter(Mandatory = $true)]
  [string]$Archive,

  [string]$Suite = "all"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
if ($PSVersionTable.PSVersion.Major -ge 7) {
  $PSNativeCommandUseErrorActionPreference = $true
}

trap {
  if ($env:GITHUB_ACTIONS) {
    $message = $_.Exception.Message.Replace('%', '%25').Replace("`r", '%0D').Replace("`n", '%0A')
    Write-Host "::error title=Windows release test failed::$message"
  }
  break
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
Set-Location $repoRoot

. "$PSScriptRoot/windows-dll-deps.ps1"

$node = (Get-Command node.exe).Source
$workDir = if ($env:MOMINER_RELEASE_TEST_DIR) { $env:MOMINER_RELEASE_TEST_DIR } else { "release-test" }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $Archive).Path)
try {
  $rootEntry = $zip.Entries | Where-Object { $_.FullName -match '^[^/\\]+[/\\]$' } | Select-Object -First 1
  $root = if ($rootEntry) { $rootEntry.FullName.TrimEnd('/', '\') } else { "" }
  if (-not $root) {
    $root = (($zip.Entries | Select-Object -First 1).FullName -split '[/\\]')[0]
  }
  if ($zip.Entries | Where-Object { $_.FullName -match '(^|[/\\])tests([/\\]|$)' }) {
    throw "Release archive must not contain tests/."
  }
} finally {
  $zip.Dispose()
}

Remove-Item -Recurse -Force $workDir -ErrorAction SilentlyContinue
Expand-Archive $Archive $workDir
$packageDir = Join-Path $workDir $root
if (Test-Path (Join-Path $packageDir "tests")) {
  throw "Extracted release package unexpectedly contains tests/."
}

$hasSyclBridge = Test-Path (Join-Path $packageDir "sycl.dll")
if (-not $hasSyclBridge) {
  throw "Windows release package is missing sycl.dll."
}
$entryPaths = @(
  (Join-Path $packageDir "mominer-node.exe"),
  (Join-Path $packageDir "mominer.node"),
  (Join-Path $packageDir "sycl.dll")
)
Test-MominerDllClosure -PackageDir $packageDir -EntryPaths $entryPaths

Copy-Item tests (Join-Path $packageDir "tests") -Recurse

$systemPath = @(
  $packageDir,
  "$env:WINDIR\System32",
  $env:WINDIR,
  "$env:WINDIR\System32\Wbem",
  "$env:WINDIR\System32\WindowsPowerShell\v1.0"
) -join ';'
$env:Path = $systemPath

function Enable-IntelOpenCL {
  if ($env:OCL_ICD_FILENAMES) {
    return
  }

  $intelOcl = Get-ChildItem -Path $packageDir -Filter "intelocl*.dll" -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($intelOcl) {
    $env:OCL_ICD_FILENAMES = $intelOcl.FullName
  }
}

function Get-SyclCpuDevicesFromOutput {
  param([Parameter(Mandatory = $true)][string[]]$Output)

  $devices = New-Object 'System.Collections.Generic.List[string]'
  foreach ($line in $Output) {
    if ($line -match '^(cpu\d+):\s+(.+)$') {
      $devices.Add($Matches[1])
    }
  }
  return $devices
}

Remove-Item Env:MOMINER_ASSUME_SYCL_CPU -ErrorAction SilentlyContinue
Enable-IntelOpenCL
Push-Location $packageDir
try {
  $oldErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $smokeOutput = & .\mominer.cmd algo_params 2>&1
  $smokeExit = $LASTEXITCODE
  $ErrorActionPreference = $oldErrorActionPreference
  if ($smokeExit -ne 0) {
    $env:MOMINER_DEBUG_STARTUP = "1"
    $ErrorActionPreference = "Continue"
    $debugOutput = & .\mominer.cmd algo_params 2>&1
    $debugExit = $LASTEXITCODE
    $ErrorActionPreference = $oldErrorActionPreference
    Remove-Item Env:MOMINER_DEBUG_STARTUP -ErrorAction SilentlyContinue
    throw "Direct executable smoke test failed with exit code $smokeExit. Output: $($smokeOutput -join ' | '). Debug exit code: $debugExit. Debug output: $($debugOutput -join ' | ')"
  }
  if (-not ($smokeOutput | Where-Object { $_ -match '^MOMINER_ALGO_PARAMS ' })) {
    throw "Direct executable smoke test did not print algo params marker.`n$($smokeOutput -join "`n")"
  }
  $marker = $smokeOutput | Where-Object { $_ -match '^MOMINER_ALGO_PARAMS ' } | Select-Object -First 1
  $params = ($marker -replace '^MOMINER_ALGO_PARAMS ', '') | ConvertFrom-Json
  foreach ($prop in $params.PSObject.Properties) {
    $dev = [string]$prop.Value
    if (-not $dev -or $dev -match '(^|,)[^,]*(\*0|\^0)(,|$)') {
      throw "Invalid algo params for $($prop.Name): $dev"
    }
  }
  $syclCpuDevices = Get-SyclCpuDevicesFromOutput $smokeOutput
  if (($Suite -eq "all" -or $Suite -eq "sycl-cpu") -and $syclCpuDevices.Count -eq 0) {
    throw "Windows $Suite release test requires a CPU SYCL device, but algo_params did not report one.`n$($smokeOutput -join "`n")"
  }

  function Invoke-HashSuite {
    param([string]$Name)
    if ($Name -eq "sycl-cpu") {
      Enable-IntelOpenCL
    }
    & $node tests/run_hash.js $Name
    if ($LASTEXITCODE -ne 0) {
      throw "Hash suite failed: $Name"
    }
  }

  switch ($Suite) {
    "all" {
      Enable-IntelOpenCL
      & $node tests/run_hash.js
      if ($LASTEXITCODE -ne 0) {
        throw "Hash suite failed: all"
      }
    }
    "cpu" { Invoke-HashSuite "cpu" }
    "sycl-cpu" { Invoke-HashSuite "sycl-cpu" }
    "gpu" { Invoke-HashSuite "gpu" }
    default { throw "Unknown release test suite: $Suite" }
  }
} finally {
  Pop-Location
}
