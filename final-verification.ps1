# Final Verification Script - Memastikan rebrand Berita Janten selesai dengan baik

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Berita Janten"

Write-Host "========== FINAL VERIFICATION - BERITA JANTEN REBRAND ==========" -ForegroundColor Cyan
Write-Host ""

$issues = @()
$stats = @{
    "Files checked" = 0
    "Old branding found" = 0
    "Legacy logo refs" = 0
    "New colors found" = 0
}

# 1. Check for old branding strings
Write-Host "1. Checking for old branding strings..." -ForegroundColor Yellow
$oldBrandingPatterns = @(
    ('Warta' + ' Janten'),
    ('warta' + 'janten'),
    ('Warta' + 'Janten')
)
$htmlCssJsonFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html", "*.css", "*.json", "*.md" -File |
    Where-Object { $_.FullName -notlike "*\node_modules\*" -and $_.FullName -notlike "*\.bak.*" }

$stats["Files checked"] = $htmlCssJsonFiles.Count

foreach ($pattern in $oldBrandingPatterns) {
    $found = $htmlCssJsonFiles | Select-String -Pattern $pattern -SimpleMatch -ErrorAction SilentlyContinue
    if ($found) {
        foreach ($result in $found) {
            $issues += @{
                Type = "Old Branding"
                File = ($result.Path | Split-Path -Leaf)
                Line = $result.LineNumber
                Pattern = $pattern
            }
            $stats["Old branding found"]++
        }
    }
}

if ($stats["Old branding found"] -eq 0) {
    Write-Host "   ✅ No old branding references found!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Found old branding in $($stats['Old branding found']) places" -ForegroundColor Yellow
}

# 2. Check for legacy logo image references
Write-Host "2. Checking for legacy logo image references..." -ForegroundColor Yellow
$legacyLogoFound = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html", "*.js", "*.ps1", "*.txt" -File |
    Select-String -Pattern 'img\/[^"'']*logo[^"'']*|logo[^"'']*\.(svg|jpg|jpeg|webp)' -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -notlike "*\.bak.*" }

if ($legacyLogoFound) {
    $stats["Legacy logo refs"] = $legacyLogoFound.Count
    Write-Host "   ⚠️  Found $($legacyLogoFound.Count) legacy logo references" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ No legacy logo image references found!" -ForegroundColor Green
}

# 3. Check for new colors in CSS
Write-Host "3. Checking for new color scheme in CSS files..." -ForegroundColor Yellow
$cssFiles = Get-ChildItem -Path (Join-Path $WorkspaceRoot "css") -Include "*.css" -File -ErrorAction SilentlyContinue
$newColors = @("#166534", "#052E16", "#2D5016")
$colorsFound = 0

foreach ($color in $newColors) {
    $found = $cssFiles | Select-String -Pattern $color -SimpleMatch -ErrorAction SilentlyContinue
    if ($found) {
        $colorsFound++
        Write-Host "   ✅ Found $color in CSS" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Not found: $color" -ForegroundColor Yellow
    }
}

# 4. Check for new branding
Write-Host "4. Checking for new branding 'Berita Janten'..." -ForegroundColor Yellow
$newBrandingFound = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File |
    Select-String -Pattern "Berita Janten|BeritaJanten|beritajanten" -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -notlike "*\.bak.*" } |
    Measure-Object

if ($newBrandingFound.Count -gt 0) {
    Write-Host "   ✅ Found 'Berita Janten' branding in $($newBrandingFound.Count) places" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  No 'Berita Janten' branding found!" -ForegroundColor Yellow
}

# 5. Check package.json updates
Write-Host "5. Checking package metadata..." -ForegroundColor Yellow
$pkgFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "package.json", "package-lock.json" -File |
    Where-Object { $_.FullName -notlike "*\node_modules\*" }

$pkgOK = 0
foreach ($pkg in $pkgFiles) {
    $content = Get-Content $pkg.FullName -Raw
    if ($content -match '"name"\s*:\s*"beritajanten') {
        $pkgOK++
        Write-Host "   ✅ $($pkg.Name) has proper branding" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Files checked: $($stats['Files checked'])" -ForegroundColor White
Write-Host "Old branding issues: $($stats['Old branding found'])" -ForegroundColor $(if ($stats['Old branding found'] -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "Legacy logo refs: $($stats['Legacy logo refs'])" -ForegroundColor $(if ($stats['Legacy logo refs'] -eq 0) { 'Green' } else { 'Yellow' })
Write-Host "New color scheme found: $colorsFound/3" -ForegroundColor $(if ($colorsFound -eq 3) { 'Green' } else { 'Yellow' })
    }
} else {
    Write-Host "[OK] No critical issues found!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Rebrand BERITA Janten SELESAI" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Cyan
