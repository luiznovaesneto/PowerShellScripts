# Passo 1: Receber os parâmetros namespace e contains
param (
    [string]$namespace
)

$output = kubectl get rs --namespace $namespace

$lines = $output -split "`n"

$data = $lines[1..($lines.Length - 1)] | Where-Object { $_ -match '\S' }

# Transforme os dados em objetos
$objects = $data | ForEach-Object {
    $fields = $_ -split '\s+'
    [PSCustomObject]@{
        name = $fields[0]
        desired = [int]($fields[1])
        current = [int]($fields[2])
        ready = [int]($fields[3])
        age = $fields[4]
    }
}


$objects = $objects | Where-Object { $_.desired -eq 0 }


$filteredObjects = $objects | Where-Object { $_.desired -eq 0 }

foreach ($object in $filteredObjects) {
    $rsName = $object.name
    kubectl delete rs -n $namespace $rsName
}