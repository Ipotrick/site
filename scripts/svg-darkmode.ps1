# Adds a prefers-color-scheme: dark style block to diagram SVGs so their neutral colors
# (text, grid lines, box outlines) flip for dark backgrounds; colored shapes are untouched.
# Works when the SVG is used as <img>. Safe to re-run: files that already have the block are skipped.
# Usage: pwsh scripts/svg-darkmode.ps1 content/blogs/<post>/images
param([Parameter(Mandatory)][string]$Dir)

$css = @'
<style>@media (prefers-color-scheme:dark){
[fill="rgb(11, 11, 11)"]{fill:#e3e5e9}
[fill="rgb(82, 81, 78)"]{fill:#aeb6c2}
[stroke="rgb(82, 81, 78)"]{stroke:#aeb6c2}
[fill="rgb(195, 194, 183)"]{fill:#6b7280}
[stroke="rgb(195, 194, 183)"]{stroke:#6b7280}
[stroke="rgba(11,11,11,0.1)"]{stroke:rgba(255,255,255,.16)}
}</style>
'@ -replace "`r?`n", ''

foreach ($f in Get-ChildItem $Dir -Filter *.svg) {
    $t = [IO.File]::ReadAllText($f.FullName)
    if ($t -match 'prefers-color-scheme') { Write-Host "skip  $($f.Name)"; continue }
    $t = [regex]::Replace($t, '(<svg\b[^>]*>)', '$1' + $css.Replace('$', '$$'), 1)
    [IO.File]::WriteAllText($f.FullName, $t, (New-Object Text.UTF8Encoding($false)))
    Write-Host "dark  $($f.Name)"
}
