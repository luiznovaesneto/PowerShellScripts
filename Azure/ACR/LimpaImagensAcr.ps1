# Par?metros
$acrName = "aksbrscontainer01"  # Substitua pelo nome do seu ACR
$keep = 2                       # Quantidade de imagens a manter
$azCli = "az"

# Verifica se o Azure CLI est? instalado
if (-not (Get-Command $azCli -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI (az) n?o encontrado. Instale o Azure CLI antes de executar este script."
    exit 1
}

Write-Output "?? Efetuando login no ACR..."
az acr login --name $acrName | Out-Null

$repos = az acr repository list --name $acrName --output json | ConvertFrom-Json

foreach ($repo in $repos) {
    Write-Output "`n?? Processando reposit?rio: $repo"

    # ? Forma correta de chamar list-metadata
    $manifestsJson = az acr manifest list-metadata --name $repo --registry $acrName --output json 2>&1 | Where-Object { $_ -notmatch "WARNING: Command group 'acr manifest'" }

    if (-not $manifestsJson -or $manifestsJson -eq "[]") {
        Write-Output "??  Nenhum manifest encontrado para $repo. Pulando..."
        continue
    }

    $manifests = $manifestsJson | ConvertFrom-Json

    if ($manifests.Count -le $keep) {
        Write-Output "? Apenas $($manifests.Count) imagens encontradas. Nada ser? exclu?do."
        continue
    }

    $sorted = $manifests | Sort-Object {
        [DateTime]::ParseExact(
            $_.lastUpdateTime,
            'MM/dd/yyyy HH:mm:ss',
            [System.Globalization.CultureInfo]::InvariantCulture
        )
    } -Descending
    $toDelete = $sorted[$keep..($sorted.Count - 1)]

    foreach ($m in $toDelete) {
        $digest = $m.digest
        $image = "$repo@$digest"
        Write-Output "???  Excluindo imagem: $image"
        az acr repository delete --name $acrName --image $image --yes | Out-Null
    }
}

Write-Output "`n?? Limpeza finalizada com sucesso!"