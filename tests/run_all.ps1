# tests/run_all.ps1
# Ejecuta todas las pruebas de comandos docker scout (multi-plataforma)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "=== Ejecutando pruebas de comandos docker scout ===" -ForegroundColor Yellow

$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Lista de scripts de prueba
$tests = @(
    "test_cves.ps1",
    "test_quickview.ps1",
    "test_compare.ps1",
    "test_recommendations.ps1",
    "test_policy.ps1"
)

# Detectar qué ejecutable de PowerShell usar (Windows: powershell, Linux: pwsh)
$psExe = $null
if (Get-Command powershell -ErrorAction SilentlyContinue) {
    $psExe = "powershell"
}
elseif (Get-Command pwsh -ErrorAction SilentlyContinue) {
    $psExe = "pwsh"
}
else {
    Write-Host "❌ No se encontró ningún ejecutable de PowerShell (powershell / pwsh)." -ForegroundColor Red
    exit 1
}

foreach ($t in $tests) {
    $scriptPath = Join-Path $basePath $t
    Write-Host "`n--- Ejecutando $t ---`n" -ForegroundColor Cyan

    & $psExe -ExecutionPolicy Bypass -File $scriptPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n❌ Alguna prueba falló. Deteniendo ejecución." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✅ Todas las pruebas de comandos docker scout se ejecutaron correctamente." -ForegroundColor Green
exit 0
