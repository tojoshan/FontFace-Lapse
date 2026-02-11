
$files = Get-ChildItem "extensions\download0\*.ts"

foreach ($file in $files) {
    if ($file.Name -eq "loader.ts") { continue } # Skip loader, we use our own entry

    Write-Host "Processing $($file.Name)..."
    $content = Get-Content -Path $file.FullName -Raw

    # 1. Remove imports of 'include' and other weirdness
    $content = $content -replace "include\('[^']+'\)", ""
    $content = $content -replace "import {[^}]+} from 'download0/defs'", "" # Strip defs import (make_uaf) as we rely on webkit.js

    # 2. Fix imports to .mjs
    $content = $content -replace "from 'download0/([^']+)'", "from './`$1.mjs'"
    $content = $content -replace "from '\./([^']+)\.js'", "from './`$1.mjs'"

    # 3. Remove type definitions
    $content = $content -replace "(?m)^type\s+\w+\s*=[\s\S]*?$", "" 
    $content = $content -replace "(?m)^interface\s+\w+[\s\S]*?^}", ""
    
    # 4. Remove type annotations
    $types = "number|string|BigInt|void|any|unknown|boolean|object|symbol"
    $content = $content -replace ":\s*($types)(\[\])?", ""
    $content = $content -replace "\s+as\s+\w+", ""
    $content = $content -replace "<[A-Z][A-Za-z0-9_]*>", "" # Generics <T>
    
    # 5. Specific fixes for types.ts
    if ($file.Name -eq "types.ts") {
        # Inject globals that are used but not defined (assumed global in original context)
        # We export them so other modules can use/set them.
        $globals = "
export let master = new Uint32Array(8);
export let slave = new DataView(new ArrayBuffer(16));
export let leak_obj = { obj: null };
export let leak_obj_addr = new BigInt(0);
export let uaf_view = new DataView(new ArrayBuffer(0)); // Placeholder
"
        $content = $globals + $content
        
        # Remove "declare global" block
        $content = $content -replace "(?m)declare global\s*\{[\s\S]*?\}", ""
        
        # Remove DataView interface augmentation inside global (already handled by regex but ensure)
    }

    # 6. Specific fixes for userland.ts
    if ($file.Name -eq "userland.ts") {
        # Remove redeclaration of master/slave if present (it is let master in ts)
        # userland.ts has: let master: Uint32Array | undefined
        # We want to import it from types.mjs instead.
        $content = "import { master, slave, leak_obj, leak_obj_addr, uaf_view } from './types.mjs';" + "`n" + $content
        $content = $content -replace "let master\s*(=|:)", "// let master $1"
        $content = $content -replace "const slave\s*(=|:)", "// const slave $1"
        $content = $content -replace "let master_addr\s*(=|:)", "let master_addr $1" # master_addr is local?
        
        # Remove UAF logic (we use webkit.js RW)
        # We need to preserve the PART 2: finding addresses.
        # Find where "Initiate ARW" or "addrof(Math.min)" happens.
        # In chunk 0: log('Initiate UAF...')...
        # We should comment out everything before "const math_min_addr = mem.addrof(Math.min)"
        # But variables like u32_structs might be needed?
        
        # For now, just comment out the UAF calls if possible, or we will handle this manually later.
        $content = $content -replace "make_uaf\(uaf_view\)", "// make_uaf(uaf_view) - SKIPPED"
        
        # We need to bridge webkit.js primitives to 'mem' in types.mjs.
        # This is tricky because mem implementation in types.mjs uses master/slave directly.
        # We need to INIT master/slave using webkit.js primitives.
    }

    # Write to .mjs
    $dest = "extensions/netctrl/" + $file.BaseName + ".mjs"
    $parent = Split-Path $dest
    if (!(Test-Path $parent)) { mkdir $parent -Force }
    Set-Content -Path $dest -Value $content
}
