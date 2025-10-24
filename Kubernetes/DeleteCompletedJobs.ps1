param (
    [string]$namespace
)

if (-not $namespace) {
    Write-Host "Por favor, forneça o namespace como argumento."
    exit
}

# Obtém todos os jobs no namespace especificado
$jobsJson = kubectl get jobs -n $namespace -o json
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao obter os jobs no namespace $namespace."
    exit
}

$jobs = $jobsJson | ConvertFrom-Json

# Verifica se há jobs no namespace
if (-not $jobs.items) {
    Write-Host "Nenhum job encontrado no namespace $namespace."
    exit
}

# Itera sobre cada job
foreach ($job in $jobs.items) {
    # Verifica se o job está completo (COMPLETIONS = 1/1)
    if ($job.status.succeeded -eq 1 -and $job.spec.completions -eq 1) {
        # Obtém o nome do job
        $jobName = $job.metadata.name

        # Apaga o job
        kubectl delete job $jobName -n $namespace
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Job $jobName deleted"
        } else {
            Write-Host "Erro ao deletar o job $jobName"
        }
    }
}
