param (
    [string]$namespace
)

# Verifica se o namespace foi fornecido
if (-not $namespace) {
    Write-Host "Por favor, forneça o nome do namespace."
    exit
}

# Obtém todos os ReplicaSets no namespace especificado
$replicaSets = kubectl get replicasets --namespace=$namespace -o=json | ConvertFrom-Json

# Itera sobre cada ReplicaSet
foreach ($rs in $replicaSets.items) {
    # Verifica se o ReplicaSet não tem pods associados
    if ($rs.status.replicas -eq 0) {
        # Deleta o ReplicaSet
        kubectl delete replicaset $rs.metadata.name --namespace=$namespace
    }
}