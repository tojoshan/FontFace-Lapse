
$files = Get-ChildItem "extensions\download0\*.ts"

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    # Replace 'download0/xxx' with './xxx.js'
    $content = $content -replace "'download0/([^']+)'", "'./`$1.js'"
    # Remove include('...') lines
    $content = $content -replace "include\('[^']+'\)", "// include removed"

    Set-Content -Path $file.FullName -Value $content
}
