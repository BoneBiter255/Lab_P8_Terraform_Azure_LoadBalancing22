#!/usr/bin/env pwsh

# Deploy script for Lab 8 Terraform Azure

$ErrorActionPreference = "Stop"

Write-Host "=== Lab 8 Terraform Azure Deployment ===" -ForegroundColor Cyan

# Cambiar al directorio infra
Push-Location infra

try {
    # 1. Validar
    Write-Host "`n[1/4] Validando configuracion..." -ForegroundColor Yellow
    terraform validate
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Validacion OK" -ForegroundColor Green
    } else {
        Write-Host "Error en validacion" -ForegroundColor Red
        exit 1
    }

    # 2. Plan
    Write-Host "`n[2/4] Generando plan..." -ForegroundColor Yellow
    terraform plan `
        `"-var-file=env/dev.tfvars`" `
        -out=tfplan.out

    # 3. Presentar plan
    Write-Host "`n=== Plan Generado ===" -ForegroundColor Cyan
    Write-Host "Revisa el plan arriba. Para aplicar, ejecuta:"
    Write-Host "  terraform apply tfplan.out" -ForegroundColor Green

    # 4. Preguntar si continuar
    Write-Host "`nDeseas continuar con apply? (s/n)" -ForegroundColor Yellow
    $response = Read-Host
    
    if ($response -eq 's') {
        Write-Host "`n[3/4] Aplicando cambios..." -ForegroundColor Yellow
        terraform apply tfplan.out

        Write-Host "`n[4/4] Obteniendo outputs..." -ForegroundColor Yellow
        $LB_IP = terraform output -raw lb_public_ip
        $RG = terraform output -raw resource_group_name
        $VMS = terraform output -json vm_names | ConvertFrom-Json

        Write-Host "`n=== Infraestructura Desplegada ===" -ForegroundColor Green
        Write-Host "Load Balancer IP: $LB_IP"
        Write-Host "Resource Group:   $RG"
        Write-Host "VMs:              $($VMS -join ', ')"
        Write-Host "`nPrueba el LB en: http://$LB_IP"
    } else {
        Write-Host "`nDeploy cancelado." -ForegroundColor Yellow
        Write-Host "Para aplicar luego, ejecuta: terraform apply tfplan.out"
    }

} catch {
    Write-Host "`nError durante el despliegue:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
} finally {
    Pop-Location
}
