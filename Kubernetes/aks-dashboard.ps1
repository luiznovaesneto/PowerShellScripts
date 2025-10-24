Start-Job { kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 }

Start-Sleep -Seconds 3

Start-Process "https://localhost:8443"

# Mantém o script aberto para ver logs
Write-Host "Port-forward em execução. Pressione Ctrl+C para parar."
Wait-Job -State Running
