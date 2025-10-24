# Execute o comando kubectl e armazene a saída em uma variável
$output = kubectl top pods --all-namespaces

# Separe as linhas da saída em um array
$lines = $output -split "`n"

# Remova o cabeçalho e quaisquer linhas em branco
$data = $lines[1..($lines.Length - 1)] | Where-Object { $_ -match '\S' }

# Transforme os dados em objetos
$objects = $data | ForEach-Object {
    $fields = $_ -split '\s+'
    [PSCustomObject]@{
        Namespace = $fields[0]
        PodName = $fields[1]
        CPUUsage = $fields[2]
        MemoryUsage = $fields[3]
    }
}

# Ordene os objetos pelo uso de memória (converta de MiB para inteiros)
$sortedObjects = $objects | Sort-Object {[int]($_.MemoryUsage -replace 'Mi', '')} -Descending

# Exiba os objetos ordenados em uma tabela
$sortedObjects | Format-Table -AutoSize