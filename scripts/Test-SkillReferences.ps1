[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $projectRoot '.agents\skills'
$failures = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
    throw "Skills directory not found: $skillsRoot"
}

$skillFiles = @(Get-ChildItem -LiteralPath $skillsRoot -Recurse -Filter 'SKILL.md' -File)
foreach ($skillFile in $skillFiles) {
    $content = Get-Content -LiteralPath $skillFile.FullName -Raw
    $relativeSkillPath = $skillFile.FullName.Substring($projectRoot.Length + 1)

    if (-not $content.StartsWith('---')) {
        $failures.Add("Missing YAML frontmatter: $relativeSkillPath")
        continue
    }

    $nameMatch = [regex]::Match($content, '(?m)^name:\s*([^\r\n]+)$')
    $descriptionMatch = [regex]::Match($content, '(?m)^description:\s*([^\r\n]+)$')
    if (-not $nameMatch.Success) {
        $failures.Add("Missing frontmatter name: $relativeSkillPath")
    } elseif ($nameMatch.Groups[1].Value.Trim() -ne $skillFile.Directory.Name) {
        $failures.Add("Skill name does not match folder: $relativeSkillPath")
    }
    if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups[1].Value)) {
        $failures.Add("Missing frontmatter description: $relativeSkillPath")
    }
}

$markdownFiles = @(Get-ChildItem -LiteralPath $skillsRoot -Recurse -Filter '*.md' -File)
foreach ($markdownFile in $markdownFiles) {
    $lineNumber = 0
    foreach ($line in (Get-Content -LiteralPath $markdownFile.FullName)) {
        $lineNumber++
        foreach ($match in [regex]::Matches($line, '`([^`]+\.md)`')) {
            $reference = $match.Groups[1].Value
            if ($reference -match '^https?://' -or $reference -match '^[A-Za-z]:\\') {
                continue
            }

            $candidate = Join-Path $markdownFile.DirectoryName ($reference -replace '/', '\')
            $resolvedCandidate = [System.IO.Path]::GetFullPath($candidate)
            $inventoryRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot 'inventory'))
            if ($resolvedCandidate.StartsWith($inventoryRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
                continue
            }
            if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
                $relativeMarkdownPath = $markdownFile.FullName.Substring($projectRoot.Length + 1)
                $failures.Add("Unresolved Markdown reference at ${relativeMarkdownPath}:$lineNumber -> $reference")
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "Skill reference validation failed with $($failures.Count) finding(s)."
}

Write-Host "Skill reference validation passed for $($skillFiles.Count) skills."
