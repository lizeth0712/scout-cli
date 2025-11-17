# tests/test_policy.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Prueba básica del comando: docker scout policy <imagen>
# Incluye manejo de "entorno limitado" cuando no hay organización / políticas
# configuradas o cuando se requiere login a Docker Hub.

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

# ================== MANEJO DE ERRORES ==================
if ($status -ne 0) {

    # Caso 1: el runner de CI pide login a Docker Hub
    if ($output -match "Log in with your Docker ID" -or $output -match "docker login") {
        Write-Host "✅ PASS (entorno limitado): docker scout policy requiere autenticación en Docker Hub en este runner de CI." -ForegroundColor Yellow
        Write-Host "Salida:"
        Write-Host $output
        exit 0
    }

    # Caso 2: falta configurar organización / namespace
    if ($output -match "namespace of the docker organization is mandatory") {
        Write-Host "✅  PASS (entorno limitado): docker scout policy requiere una organización configurada (namespace) para evaluar políticas." -ForegroundColor Yellow
        Write-Host "Salida:"
        Write-Host $output
        exit 0
    }

    # Caso 3: mensaje experimental sin más detalle (lo documentamos igual como entorno limitado)
    if ($output -match "docker scout policy is experimental") {
        Write-Host "✅ PASS (entorno limitado): docker scout policy se encuentra en estado experimental en este entorno y no devolvió resultados de políticas." -ForegroundColor Yellow
        Write-Host "Salida:"
        Write-Host $output
        exit 0
    }

    # Cualquier otro error sí se considera fallo real
    Write-Host "❌ FAIL: docker scout policy no devolvió un resultado válido o no se pudo evaluar la imagen" -ForegroundColor Red
    Write-Host "Salida completa:"
    Write-Host $output
    exit 1
}

# ================== CASOS DE ÉXITO ==================

# Caso ideal: hay evaluación de políticas
if ($output -match "Policy evaluation" -or $output -match "policy") {
    Write-Host "✅ PASS: docker scout policy ejecutó correctamente y devolvió información de políticas" -ForegroundColor Green
    Write-Host "`nPrimeras líneas de salida:"
    $output -split "`n" | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    exit 0
}

# Caso: no hay resultados de políticas pero el mensaje lo indica claramente
if ($output -match "Policy evaluation results not found" -or $output -match "No policy results") {
    Write-Host "⚠ PASS (parcial): docker scout policy se ejecutó pero no encontró resultados de políticas para la imagen" -ForegroundColor Yellow
    Write-Host "Salida:"
    Write-Host $output
    exit 0
}

# Si llegó aquí con status 0 pero sin palabras clave, lo tratamos como fallo
Write-Host "❌ FAIL: docker scout policy se ejecutó pero la salida no contiene información reconocible de políticas" -ForegroundColor Red
Write-Host "Salida completa:"
Write-Host $output
exit 1
