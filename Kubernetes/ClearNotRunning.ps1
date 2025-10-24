param (
    [string]$namespace
)

# Verifica se o namespace foi fornecido
if (-not $namespace) {
    Write-Host "Por favor, forneça o nome do namespace."
    exit
}


# Obtém todos os pods no namespace especificado
$pods = kubectl get pods --namespace=$namespace -o=json | ConvertFrom-Json

# Itera sobre cada pod
foreach ($pod in $pods.items) {
    # Verifica se o status do pod não é "RUNNING"
    if ($pod.status.phase -ne "Running") {
        # Deleta o pod
        kubectl delete pod $pod.metadata.name --namespace=$namespace
    }
}