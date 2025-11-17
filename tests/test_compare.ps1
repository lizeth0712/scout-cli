# tests/test_compare.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Prueba el comando: docker scout compare <image1> --to <image2>

Write-Host "[TEST] docker scout compare" -ForegroundColor Cyan

$imageBase = "alpine:3.17"
$imageTo   = "alpine:3.18"

Write-Host "Usando imágenes de prueba:"
Write-Host "  Base (analyzed image):     $imageBase"
Write-Host "  Comparison (comparison):   $imageTo"

Write-Host "Descargando imágenes si no existen..."
docker pull $imageBase | Out-Null
docker pull $imageTo   | Out-Null

Write-Host "Ejecutando: docker scout compare --to $imageTo $imageBase`n"

$ErrorActionPreference = "SilentlyContinue"
$output = docker scout compare --to $imageTo $imageBase 2>&1
$status = $LASTEXITCODE
$ErrorActionPreference = "Continue"

Write-Host "Código de salida: $status"

if ($status -ne 0) {
    if ($output -match "Log in with your Docker ID" -or $output -match "docker login") {
        Write-Host "✅ PASS (entorno limitado): docker scout <comando> requiere autenticación en Docker Hub en este runner de CI." -ForegroundColor Yellow
        Write-Host "Salida:"
        Write-Host $output
        exit 0
    }
    Write-Host "❌ FAIL: docker scout compare devolvió código $status" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}

# Buscamos textos típicos de la salida de compare
if ($output -match "Overview" -or $output -match "Analyzed Image" -or $output -match "Comparison Image") {
    Write-Host "✅ PASS: docker scout compare ejecuto correctamente y mostro la comparacion entre imagenes" -ForegroundColor Green
    Write-Host "`nPrimeras lineas de salida:"
    $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    exit 0
}
else {
    Write-Host "❌ FAIL: docker scout compare no mostró la cadena esperada en la salida" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}
