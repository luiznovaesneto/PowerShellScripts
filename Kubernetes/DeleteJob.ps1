# Passo 1: Receber os parâmetros namespace e contains
param (
    [string]$namespace,
    [string]$contains
)

# Passo 2: Listar todos os jobs no namespace
$jobs = kubectl get jobs --namespace $namespace -o custom-columns="NAME:.metadata.name" | Where-Object { $_ -like "*$contains*" }

# Passo 3: Verificar se há jobs para mostrar
if ($jobs.Count -eq 0) {
    Write-Host "Nenhum job encontrado no namespace '$namespace' que contenha '$contains' no nome."
    exit
}

# Passo 4: Mostrar a lista filtrada
Write-Host "Jobs no namespace '$namespace' que contêm '$contains' no nome:"
$jobs

# Passo 5: Perguntar se deseja continuar com a exclusão
$confirmacao = Read-Host "Deseja continuar com a exclusão dos jobs listados? (S/N)"
if ($confirmacao -eq "S" -or $confirmacao -eq "s") {
    # Passo 6: Excluir os jobs
    foreach ($job in $jobs) {
        kubectl delete job $job --namespace $namespace
        Write-Host "Job '$job' excluído com sucesso."
    }
} else {
    Write-Host "Exclusão cancelada."
}
