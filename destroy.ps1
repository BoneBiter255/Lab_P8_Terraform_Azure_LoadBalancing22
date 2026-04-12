#!/usr/bin/env pwsh

# Destroy script for Lab 8 Terraform Azure

$ErrorActionPreference = "Stop"

Write-Host "=== Lab 8 Terraform Azure Destruction ===" -ForegroundColor Red

# Cambiar al directorio infra
Push-Location infra

try {
    # 1. Plan destroy
    Write-Host "`n[1/2] Generando plan de destruccion..." -ForegroundColor Yellow
    terraform plan `
        `"-var-file=env/dev.tfvars`" `
        -destroy `
        -out=destroy.tfplan

    # 2. Preguntar si continuar (doble confirmacion)
    Write-Host "`n=== ADVERTENCIA ===" -ForegroundColor Red
    Write-Host "Esto DESTRUIRA todos los recursos:"
    Write-Host "  - Load Balancer"
    Write-Host "  - Virtual Machines"
    Write-Host "  - Virtual Network"
    Write-Host "  - Network Interfaces y Security Groups"
    Write-Host ""

    Write-Host "Deseas continuar? Escribe 'destruir' para confirmar:" -ForegroundColor Yellow
    $response = Read-Host

    if ($response -eq "destruir") {
        Write-Host "`n[2/2] Destruyendo infraestructura..." -ForegroundColor Red
        terraform apply destroy.tfplan

        Write-Host "`nInfraestructura destruida exitosamente." -ForegroundColor Green
        Write-Host "`nNota: El backend remoto (RG, Storage Account) NO fue destruido."
        Write-Host "Si quieres eliminarlo, usa Azure CLI o el Portal."
    } else {
        Write-Host "`nDestruccion cancelada." -ForegroundColor Yellow
    }

} catch {
    Write-Host "`nError durante la destruccion:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
} finally {
    Pop-Location
}
