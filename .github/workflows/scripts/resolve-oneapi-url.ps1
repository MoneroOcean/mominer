param(
  [Parameter(Mandatory = $true)]
  [string]$DownloadPage,

  [Parameter(Mandatory = $true)]
  [string]$PackageName,

  [Parameter(Mandatory = $false)]
  [string]$IntelCiVariable = "WINDOWS_TOOLKIT_URL"
)

$ErrorActionPreference = "Stop"

$escapedPackage = [regex]::Escape($PackageName)

function Assert-OneApiInstallerUrl {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Url
  )

  $validRegex =
    '^https://registrationcenter-download\.intel\.com/[^''"<>\s]+/' +
    $escapedPackage +
    '-[0-9][^''"<>\s]*(_offline)?\.exe(\?.*)?$'

  if ($Url -notmatch $validRegex) {
    throw "Resolved URL does not look like a valid Intel oneAPI installer URL for ${PackageName}: $Url"
  }
}

if ($DownloadPage -match '\.exe($|\?)') {
  Assert-OneApiInstallerUrl -Url $DownloadPage
  Write-Output $DownloadPage
  exit 0
}

try {
  $page = Invoke-WebRequest `
    -UseBasicParsing `
    -Uri $DownloadPage `
    -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/125.0 Safari/537.36"
} catch {
  throw "Failed to fetch Intel oneAPI URL source '$DownloadPage': $($_.Exception.Message)"
}

$escapedVariable = [regex]::Escape($IntelCiVariable)

# Preferred source: Intel's own oneapi-src/oneapi-ci workflow variable.
$ciRegex =
  '(?m)^\s*{0}\s*:\s*[''"]?(?<url>https://registrationcenter-download\.intel\.com/[^''"<>\s]+/{1}-[0-9][^''"<>\s]*_offline\.exe)[''"]?\s*$' `
  -f $escapedVariable, $escapedPackage

$match = [regex]::Match($page.Content, $ciRegex)

# Fallback: find the first matching official Intel offline installer URL in the source.
if (-not $match.Success) {
  $fallbackRegex =
    'https://registrationcenter-download\.intel\.com/[^''"<>\s]+/{0}-[0-9][^''"<>\s]*_offline\.exe' `
    -f $escapedPackage

  $match = [regex]::Match($page.Content, $fallbackRegex)
}

if (-not $match.Success) {
  throw "Unable to resolve Intel oneAPI download URL for $PackageName from $DownloadPage"
}

$url = if ($match.Groups["url"].Success) {
  $match.Groups["url"].Value
} else {
  $match.Value
}

Assert-OneApiInstallerUrl -Url $url
Write-Output $url
