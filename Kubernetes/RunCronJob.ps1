param (
    [string]$n,
    [string]$c
)

# Obtém a data e hora atual no formato "YYYYMMDDHHMMSS"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Define o JOBNAME concatenando o nome do cronjob com o timestamp
$JOBNAME = "$c-manual-$timestamp"

# Cria o job usando o comando kubectl
kubectl create job -n $n --from=cronjob/$c $JOBNAME

