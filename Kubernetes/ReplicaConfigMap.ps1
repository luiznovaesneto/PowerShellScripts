param (
    [Parameter(Mandatory = $true)]
    [string]$ConfigMapName,   # Nome do ConfigMap a ser replicado

    [string]$SourceNamespace = "default"  # Namespace de origem, 'default' se não especificado
)

# Verificar se o ConfigMap existe no namespace de origem
try {
    $configMap = kubectl get configmap $ConfigMapName -n $SourceNamespace -o yaml
    if (-not $configMap) {
        Write-Output "ConfigMap '$ConfigMapName' não encontrado no namespace '$SourceNamespace'."
        exit 1
    }
}
catch {
    Write-Output "Erro ao buscar o ConfigMap '$ConfigMapName' no namespace '$SourceNamespace'."
    exit 1
}

# Obter todos os namespaces no cluster corretamente
$namespaces = kubectl get namespaces -o json | ConvertFrom-Json
$namespaceList = $namespaces.items | ForEach-Object { $_.metadata.name }

# Replicar o ConfigMap para cada namespace
foreach ($ns in $namespaceList) {
    if ($ns -ne $SourceNamespace) {
        Write-Output "Replicando ConfigMap '$ConfigMapName' para o namespace '$ns'..."
        # Substituir o namespace no yaml e aplicar no namespace de destino
        $configMap -replace "namespace: $SourceNamespace", "namespace: $ns" | kubectl apply -n $ns -f -
    }
}

Write-Output "Replicação concluída."
