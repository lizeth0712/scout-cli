# tests/test_cves.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Este script prueba el comando: docker scout cves <imagen>

Write-Host "[TEST] docker scout cves" -ForegroundColor Cyan

# Imagen de prueba (puedes cambiarla si quieres)
$image = "alpine:3.18"

Write-Host "Usando imagen de prueba: $image"

# 1. Asegurarnos de que la imagen existe localmente
Write-Host "Descargando imagen si no existe..."
docker pull $image | Out-Null

# 2. Ejecutar docker scout cves y capturar salida y código de retorno
Write-Host "Ejecutando: docker scout cves $image`n"

$ErrorActionPreference = "SilentlyContinue"
$output = docker scout cves $image 2>&1
$status = $LASTEXITCODE
$ErrorActionPreference = "Continue"

Write-Host "Código de salida: $status"

# 3. Verificar código de salida
if ($status -ne 0) {
    Write-Host "❌ FAIL: docker scout cves devolvió código $status" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}

# 4. Verificar que la salida contiene algo que parezca reporte de CVEs
if ($output -match "CVE" -or $output -match "vulnerab") {
    Write-Host "✅ PASS: docker scout cves ejecuto correctamente y mostro informacion de vulnerabilidades" -ForegroundColor Green
    # Opcional: mostrar solo las primeras líneas
    Write-Host "`nPrimeras lineas de salida:"
    $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    exit 0
}
else {
    Write-Host "❌ FAIL: docker scout cves no mostró la cadena esperada en la salida" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}
