[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$failed = $false

Write-Host 'Environment check (credential-related variable names only):'
$environmentNames = @(Get-ChildItem Env: |
    Where-Object { $_.Name -match '(?i)(TOKEN|SECRET|KEY|PASSWORD|CREDENTIAL|GITHUB|OPENAI|ANTHROPIC|GOOGLE|GROK|XAI)' } |
    Select-Object -ExpandProperty Name |
    Sort-Object -Unique)
if ($environmentNames.Count -eq 0) {
    Write-Host '  No matching variable names found.'
} else {
    $environmentNames | ForEach-Object { Write-Host "  $_" }
}

Write-Host 'Tracked-file policy check:'
$trackedFiles = @(git ls-files)
$forbiddenFiles = @($trackedFiles | Where-Object {
    $_ -match '(^|/)(\.env($|\.)|credentials/|secrets/)' -or
    $_ -match '\.(pem|key|p12|pfx|kdbx)$'
})
if ($forbiddenFiles.Count -gt 0) {
    $failed = $true
    $forbiddenFiles | ForEach-Object { Write-Error "Tracked sensitive-path pattern: $_" }
} else {
    Write-Host '  No tracked credential or key path patterns found.'
}

Write-Host 'Tracked-content marker check (filenames only):'
$markerPattern = '(gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AIza[A-Za-z0-9_-]{20,}|xai-[A-Za-z0-9_-]{20,}|-----BEGIN[[:space:]].*PRIVATE[[:space:]]KEY-----)'
$matchingFiles = @(git grep -Il -E -e $markerPattern 2>$null)
if ($matchingFiles.Count -gt 0) {
    $failed = $true
    $matchingFiles | ForEach-Object { Write-Error "Tracked secret marker in: $_" }
} else {
    Write-Host '  No common token or private-key markers found.'
}

Write-Host 'Whitespace check:'
git diff --check --cached
if ($LASTEXITCODE -ne 0) {
    $failed = $true
}

Write-Host 'Skill frontmatter and reference check:'
try {
    & (Join-Path $PSScriptRoot 'Test-SkillReferences.ps1')
} catch {
    $failed = $true
    Write-Error $_
}

if ($failed) {
    throw 'Repository safety preflight failed. Do not commit until the findings are resolved.'
}

Write-Host 'Repository safety preflight passed.'
