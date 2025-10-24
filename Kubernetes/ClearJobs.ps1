# Obtém todos os namespaces, excluindo os que começam com "kube-"
$namespaces = kubectl get namespaces --no-headers -o jsonpath="{.items[*].metadata.name}" 2>$null
$filteredNamespaces = $namespaces -split " " | Where-Object { $_ -notmatch "^kube-" }

foreach ($ns in $filteredNamespaces) {
    Write-Output "Verificando namespace: $ns"

    # Obtém todos os jobs no namespace atual
    $jobs = kubectl get jobs -n $ns --no-headers -o jsonpath="{.items[*].metadata.name}" 2>$null

    foreach ($job in $jobs -split " ") {
        # Verifica se há pods associados ao job
        $pods = kubectl get pods -n $ns --selector=job-name=$job --no-headers 2>$null

        if (-not $pods) {
            Write-Output "Deletando job: $job no namespace: $ns"
            kubectl delete job $job -n $ns
        }
    }
}
