
$files = Get-ChildItem "extensions\download0\*.ts"

foreach ($file in $files) {
    echo "Processing $file..."
    $content = Get-Content -Path $file.FullName -Raw

    # 1. Remove imports of 'include'
    $content = $content -replace "include\('[^']+'\)", ""
    
    # 2. Fix imports to .mjs
    $content = $content -replace "from 'download0/([^']+)'", "from './`$1.mjs'"
    $content = $content -replace "from '\./([^']+)\.js'", "from './`$1.mjs'"

    # 3. Remove type definitions
    # Remove 'type X = ...'
    $content = $content -replace "(?m)^type\s+\w+\s*=[\s\S]*?$", "" 
    # Remove 'interface X ...'
    $content = $content -replace "(?m)^interface\s+\w+[\s\S]*?^}", ""

    # 4. Remove type annotations in functions/variables
    # Simple regex for ': type'
    # Be careful not to match object keys or ternaries.
    # We'll skip complex stripping for now and hope it's valid JS mostly.
    # But TypeScript syntax is invalid in JS.
    # We must strip ': number', ': string', ': BigInt', ': void', ': any', ': unknown', ': boolean'
    $types = "number|string|BigInt|void|any|unknown|boolean|object|symbol"
    $content = $content -replace ":\s*($types)(\[\])?", ""
    
    # Remove 'as X'
    $content = $content -replace "\s+as\s+\w+", ""
    
    # Remove generic syntax <T>
    $content = $content -replace "<[A-Z][A-Za-z0-9_]*>", ""

    # Write to .mjs in parent directory extensions/netctrl/
    $dest = "extensions/netctrl/" + $file.BaseName + ".mjs"
    $parent = Split-Path $dest
    if (!(Test-Path $parent)) { mkdir $parent }
    
    Set-Content -Path $dest -Value $content
}
