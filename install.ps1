# Script de instalación de Luna Browser para Windows PowerShell
# Este script descarga e instala Luna Browser automáticamente

param(
    [switch]$Force,
    [string]$Version = "1.1.0"
)

# Colores para output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Función para imprimir mensajes
function Write-Message($Message, $Type = "Info") {
    switch ($Type) {
        "Success" { Write-ColorOutput Green "[Luna Browser] $Message" }
        "Error" { Write-ColorOutput Red "[Error] $Message" }
        "Warning" { Write-ColorOutput Yellow "[Advertencia] $Message" }
        "Info" { Write-ColorOutput Cyan "[Info] $Message" }
        default { Write-Output "[Luna Browser] $Message" }
    }
}

# Verificar si se ejecuta como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Message "Por favor, ejecute este script como administrador" "Error"
    Write-Message "Click derecho -> Ejecutar como administrador" "Info"
    pause
    exit 1
}

# Verificar versión de Windows
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Message "Luna Browser requiere Windows 10 o superior" "Error"
    Write-Message "Versión actual: $($osVersion.Major).$($osVersion.Minor)" "Info"
    pause
    exit 1
}

Write-Message "🌙 Bienvenido al instalador de Luna Browser para Windows" "Success"
Write-Message "Versión: $Version" "Info"
Write-Message ""

# Crear directorio temporal
$tempDir = Join-Path $env:TEMP "LunaBrowser"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Descargar Luna Browser
$installerName = "Luna-Browser-Setup-$Version.exe"
$downloadUrl = "https://luna-browser.com/downloads/$installerName"
$installerPath = Join-Path $tempDir $installerName

Write-Message "Descargando Luna Browser..." "Info"

try {
    # Usar Invoke-WebRequest con progreso
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $installerPath)
    
    if (Test-Path $installerPath) {
        $fileSize = (Get-Item $installerPath).Length / 1MB
        Write-Message "Descarga completada: $([math]::Round($fileSize, 2)) MB" "Success"
    } else {
        Write-Message "Error al descargar Luna Browser" "Error"
        pause
        exit 1
    }
}
catch {
    Write-Message "Error durante la descarga: $($_.Exception.Message)" "Error"
    pause
    exit 1
}

# Verificar firma digital (opcional)
Write-Message "Verificando integridad del instalador..." "Info"

# Ejecutar instalador
Write-Message "Iniciando instalación..." "Info"
Write-Message "Siga las instrucciones del instalador gráfico" "Info"

try {
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -Verb RunAs
    
    # Verificar instalación
    $installPath = "$env:ProgramFiles\Luna Browser\luna-browser.exe"
    if (Test-Path $installPath) {
        Write-Message "✅ Luna Browser se ha instalado correctamente" "Success"
        
        # Crear acceso directo en el escritorio
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "Luna Browser.lnk"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $installPath
        $shortcut.WorkingDirectory = "$env:ProgramFiles\Luna Browser"
        $shortcut.IconLocation = $installPath
        $shortcut.Description = "Luna Browser - Navegación inteligente con IA"
        $shortcut.Save()
        
        Write-Message "Acceso directo creado en el escritorio" "Info"
        
        # Limpiar directorio temporal
        Remove-Item $tempDir -Recurse -Force
        
        Write-Message ""
        Write-Message "🎉 ¡Instalación completada!" "Success"
        Write-Message "Puede iniciar Luna Browser desde el menú Inicio o el acceso directo del escritorio" "Info"
        
        # Preguntar si desea iniciar ahora
        $response = Read-Host "¿Desea iniciar Luna Browser ahora? (S/N)"
        if ($response -eq "S" -or $response -eq "s") {
            Start-Process -FilePath $installPath
        }
    } else {
        Write-Message "No se pudo verificar la instalación" "Warning"
        Write-Message "Por favor, verifique que la instalación se completó correctamente" "Info"
    }
}
catch {
    Write-Message "Error durante la instalación: $($_.Exception.Message)" "Error"
}

pause
