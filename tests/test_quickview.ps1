# tests/test_quickview.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Este script prueba el comando: docker scout quickview <imagen>

Write-Host "[TEST] docker scout quickview" -ForegroundColor Cyan

$image = "alpine:3.18"
Write-Host "Usando imagen de prueba: $image"

Write-Host "Descargando imagen si no existe..."
docker pull $image | Out-Null

Write-Host "Ejecutando: docker scout quickview $image`n"

$ErrorActionPreference = "SilentlyContinue"
$output = docker scout quickview $image 2>&1
$status = $LASTEXITCODE
$ErrorActionPreference = "Continue"

Write-Host "Código de salida: $status"

# 1. Verificar código de salida
if ($status -ne 0) {
    Write-Host "❌ FAIL: docker scout quickview devolvió código $status" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}

# 2. Verificar que la salida contiene algo razonable para quickview
#    Usamos textos que sí aparecieron en tu salida real: "Target" y "View vulnerabilities".
if ($output -match "Target" -or $output -match "View vulnerabilities") {
    Write-Host "✅ PASS: docker scout quickview ejecuto correctamente y mostro el resumen de la imagen" -ForegroundColor Green
    Write-Host "`nPrimeras lineas de salida:"
    $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    exit 0
}
else {
    Write-Host "❌ FAIL: docker scout quickview no mostró la cadena esperada en la salida" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}
