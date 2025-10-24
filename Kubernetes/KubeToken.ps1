# Passo 1: Chame a função "kubectl get secret"
$secrets = kubectl get secret

# Passo 2: Encontre o secret com o nome que contenha "cluster-admin"
$clusterAdminSecret = $secrets | Where-Object { $_ -match "cluster-admin" }

if ($clusterAdminSecret) {
    # Passo 3: Chame a função "kubectl describe secret NOME-SECRET"
    $secretName = ($clusterAdminSecret -split ' ')[0]
    $secretDetails = kubectl describe secret $secretName

    # Passo 4: Retorne o token
    $token = $secretDetails | Select-String "token:" | ForEach-Object { $_.ToString() -replace "token:\s+", "" }
    Write-Host $token
} else {
    Write-Host "Nenhum secret com nome contendo 'cluster-admin' encontrado."
}
