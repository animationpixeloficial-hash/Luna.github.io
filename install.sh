#!/bin/bash

# Script de instalación de Luna Browser para Ubuntu
# Este script descarga e instala Luna Browser automáticamente

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_message() {
    echo -e "${GREEN}[Luna Browser]${NC} $1"
}

print_error() {
    echo -e "${RED}[Error]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Advertencia]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[Info]${NC} $1"
}

# Verificar si se ejecuta como root
if [[ $EUID -eq 0 ]]; then
   print_error "No ejecute este script como root. Use un usuario normal."
   exit 1
fi

# Verificar si es Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    print_error "Este script está diseñado para Ubuntu."
    exit 1
fi

# Versión de Luna Browser
LUNA_VERSION="1.1.0"
LUNA_DEB="luna-browser_${LUNA_VERSION}_amd64.deb"
DOWNLOAD_URL="https://github.com/pablo/luna-browser/releases/latest/download/${LUNA_DEB}"

print_message "🌙 Bienvenido al instalador de Luna Browser"
print_message "Versión: $LUNA_VERSION"
echo

# Actualizar lista de paquetes
print_info "Actualizando lista de paquetes..."
sudo apt update

# Instalar dependencias necesarias
print_info "Instalando dependencias necesarias..."
sudo apt install -y wget curl gdebi-core

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Descargar Luna Browser
print_info "Descargando Luna Browser..."
wget -O "$LUNA_DEB" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    print_error "Error al descargar Luna Browser"
    exit 1
fi

# Verificar el paquete descargado
if [ ! -f "$LUNA_DEB" ]; then
    print_error "No se encontró el paquete descargado"
    exit 1
fi

# Instalar Luna Browser
print_info "Instalando Luna Browser..."
sudo gdebi -n "$LUNA_DEB"

if [ $? -eq 0 ]; then
    print_message "✅ Luna Browser se ha instalado correctamente"
    
    # Limpiar directorio temporal
    cd /
    rm -rf "$TEMP_DIR"
    
    print_info "Puedes iniciar Luna Browser desde el menú de aplicaciones o ejecutando 'luna-browser' en la terminal"
    print_info "Para actualizar, usa: sudo apt update && sudo apt upgrade luna-browser"
else
    print_error "Error durante la instalación"
    exit 1
fi

print_message "🎉 ¡Instalación completada!"
