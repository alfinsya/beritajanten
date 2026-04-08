# Script untuk mengganti legacy brand image dengan text-based logo di semua HTML files

$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Berita Janten"
$htmlFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File

$textBasedLogo = @"
<span style="font-weight: bold; color: #166534; font-size: 24px; letter-spacing: -0.5px;">BERITA<span style="color: #2D5016; font-weight: normal; font-size: 18px; margin-left: 2px;">JANTEN</span></span>
"@

$replaceCount = 0
$pattern = '<img[^>]*src="(?:\.\.\/)?img\/[^"'']*logo[^"'']*"[^>]*>'

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $newContent = $content -replace $pattern, $textBasedLogo

        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $replaceCount++
            Write-Host "Updated legacy logo in: $($file.Name)"
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Logo replacement complete!"
Write-Host "Total files updated: $replaceCount"
