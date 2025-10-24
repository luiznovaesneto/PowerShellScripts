# ============================================
# Script: GerarListaArquivos.ps1
# Autor: Luiz Carlos Novaes
# Descrição: Lista todos os arquivos de uma pasta informada pelo usuário
#             e gera uma planilha Excel no mesmo diretório do script.
# ============================================


# --- Configura ambiente para UTF-8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$OutputEncoding = [System.Text.Encoding]::UTF8
try { chcp 65001 | Out-Null } catch {}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Verifica se o módulo ImportExcel está instalado
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "O módulo ImportExcel não está instalado. Instalando agora..." -ForegroundColor Yellow
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}

# --- Solicita o caminho da pasta ao usuário
$FolderPath = Read-Host "Digite o caminho completo da pasta que deseja listar"

# --- Verifica se o caminho existe
if (-not (Test-Path $FolderPath)) {
    Write-Host "[ERRO] O caminho informado não existe." -ForegroundColor Red
    Read-Host "`nPressione Enter para sair"
    exit
}

# --- Define o diretório do script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# --- Define o caminho do Excel de saída
$ExcelPath = Join-Path $ScriptDir "ListaArquivos.xlsx"

# --- Coleta os arquivos
$Files = Get-ChildItem -Path $FolderPath -File -Recurse | Select-Object `
    @{Name="Nome do Arquivo"; Expression={$_.Name}},
    @{Name="Extensão"; Expression={$_.Extension}},
    @{Name="Caminho Completo"; Expression={$_.FullName}},
    @{Name="Tamanho (KB)"; Expression={[math]::Round($_.Length / 1KB, 2)}},
    @{Name="Última Modificação"; Expression={$_.LastWriteTime}}

# --- Tenta exportar para Excel com tratamento de erro
$exportSuccess = $false
do {
    try {
        $Files | Export-Excel -Path $ExcelPath -WorksheetName "Arquivos" -AutoSize -FreezeTopRow -Title "Lista de Arquivos" -ErrorAction Stop
        $exportSuccess = $true
    }
    catch {
        Write-Host "`n[AVISO] Não foi possível salvar o arquivo Excel." -ForegroundColor Yellow
        Write-Host "Verifique se o arquivo '$ExcelPath' está aberto no Excel." -ForegroundColor Cyan
        
        $response = Read-Host "Feche o arquivo e pressione [T] para tentar novamente ou [S] para sair"
        if ($response -match '^[sS]$') {
            Write-Host "`nSaindo do script..." -ForegroundColor Red
            exit
        }
    }
} until ($exportSuccess)

# --- Exibe mensagem final
Write-Host "`n[S U C E S S O]" -ForegroundColor Green
Write-Host "Arquivo gerado em:" -ForegroundColor White
Write-Host "$ExcelPath" -ForegroundColor Cyan

# --- Aguarda o usuário pressionar Enter antes de encerrar
Read-Host "`nPressione Enter para sair"

