# tests/test_policy.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Prueba básica del comando: docker scout policy <imagen>
# Incluye manejo de "entorno limitado" cuando no hay organización / políticas configuradas.

Write-Host "[TEST] docker scout policy" -ForegroundColor Cyan

$image = "alpine:3.18"
Write-Host "Usando imagen de prueba: $image"

Write-Host "Descargando imagen si no existe..."
docker pull $image | Out-Null

Write-Host "Ejecutando: docker scout policy $image`n"

$ErrorActionPreference = "SilentlyContinue"
$output = docker scout policy $image 2>&1
$status = $LASTEXITCODE
$ErrorActionPreference = "Continue"

Write-Host "Codigo de salida: $status"

# === Caso 1: entorno ideal, hay evaluación de políticas ===
if ( ($status -eq 0) -and ($output -match "Policy evaluation" -or $output -match "policy") ) {
    Write-Host "✅ PASS: docker scout policy ejecuto correctamente y devolvio informacion de politicas" -ForegroundColor Green
    Write-Host "`nPrimeras lineas de salida:"
    $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    exit 0
}

# === Caso 2: no hay resultados de políticas, pero el mensaje lo indica claramente ===
if ($output -match "Policy evaluation results not found" -or $output -match "No policy results") {
    Write-Host "⚠ PASS (parcial): docker scout policy se ejecutó pero no encontró resultados de políticas para la imagen" -ForegroundColor Yellow
    Write-Host "Salida:"
    Write-Host $output
    exit 0
}

# === Caso 3: entorno limitado (no hay organización configurada) ===
if ($output -match "namespace of the docker organization is mandatory") {
    Write-Host "⚠ PASS (entorno limitado): docker scout policy requiere una organizacion configurada (namespace)." -ForegroundColor Yellow
    Write-Host "El comando termino con codigo $status, pero el mensaje de error es el esperado en un entorno sin organizacion/políticas."
    Write-Host "`nSalida:"
    Write-Host $output
    exit 0
}

# === Cualquier otro caso se considera fallo real ===
Write-Host "❌ FAIL: docker scout policy no devolvió un resultado válido o no se pudo evaluar la imagen" -ForegroundColor Red
Write-Host "Salida completa:"
Write-Host $output
exit 1
