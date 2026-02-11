
$files = @(
    "netctrl_c0w_twins.ts",
    "types.ts",
    "kernel.ts",
    "defs.ts",
    "userland.ts",
    "loader.ts"
)

$base = "https://raw.githubusercontent.com/Vuemony/vue-after-free/e00c92a5563258f551781be6532b1c9f710beb0c/src/download0/"
mkdir extensions/download0 -Force

foreach ($f in $files) {
    echo "Downloading $f..."
    Invoke-WebRequest -Uri "$base$f" -OutFile "extensions/download0/$f"
}
