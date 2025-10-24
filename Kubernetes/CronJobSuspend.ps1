param (
    [Parameter(Mandatory = $true)]
    [string]$CRONJOB_NAME,

    [Parameter(Mandatory = $true)]
    [string]$NAMESPACE,

    [Parameter(Mandatory = $true)]
    [bool]$SUSPEND
)

# Cria o JSON de patch
$jsonPatch = @{
    spec = @{ suspend = $SUSPEND }
} | ConvertTo-Json -Depth 3 -Compress

# Cria arquivo temporário
$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $jsonPatch -Encoding ascii

# Executa o patch com --patch-file
try {
    $output = kubectl -n $NAMESPACE patch cronjob $CRONJOB_NAME --type=merge --patch-file $tempFile 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ CronJob '$CRONJOB_NAME' atualizado com sucesso (suspend = $SUSPEND)." -ForegroundColor Green
    } else {
        Write-Host "`n❌ Erro ao aplicar patch:" -ForegroundColor Red
        Write-Host $output -ForegroundColor Yellow
    }
}
finally {
    # Remove o arquivo temporário
    Remove-Item $tempFile -Force
}
