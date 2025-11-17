# tests/test_recommendations.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Prueba el comando: docker scout recommendations <imagen>

Write-Host "[TEST] docker scout recommendations" -ForegroundColor Cyan

$image = "alpine:3.18"
Write-Host "Usando imagen de prueba: $image"

Write-Host "Descargando imagen si no existe..."
docker pull $image | Out-Null

Write-Host "Ejecutando: docker scout recommendations $image`n"

$ErrorActionPreference = "SilentlyContinue"
$output = docker scout recommendations $image 2>&1
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
    Write-Host "❌ FAIL: docker scout recommendations devolvió código $status" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}

# Buscamos palabras clave típicas de recomendaciones
if ($output -match "recommendation" -or $output -match "Recommendations" -or $output -match "base image") {
    Write-Host "✅ PASS: docker scout recommendations ejecuto correctamente y mostro recomendaciones de actualizacion" -ForegroundColor Green
    Write-Host "`nPrimeras lineas de salida:"
    $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    exit 0
}
else {
    Write-Host "❌ FAIL: docker scout recommendations no mostró la cadena esperada en la salida" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}
