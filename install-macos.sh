#!/bin/bash

# Script de instalación de Luna Browser para macOS
# Este script descarga e instala Luna Browser automáticamente

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_macos() {
    echo -e "${PURPLE}[macOS]${NC} $1"
}

# Verificar si es macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Este script está diseñado para macOS"
    exit 1
fi

# Verificar versión de macOS
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)

if [[ $MACOS_MAJOR -lt 11 ]]; then
    print_warning "Se recomienda macOS 11 (Big Sur) o superior"
    print_info "Versión actual: $MACOS_VERSION"
    
    read -p "¿Desea continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Versión de Luna Browser
LUNA_VERSION="1.1.0"
LUNA_DMG="Luna-Browser-$LUNA_VERSION.dmg"
DOWNLOAD_URL="https://luna-browser.com/downloads/$LUNA_DMG"

print_macos "🍎 Bienvenido al instalador de Luna Browser para macOS"
print_message "Versión: $LUNA_VERSION"
print_info "macOS Version: $MACOS_VERSION"
echo

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Descargar Luna Browser
print_info "Descargando Luna Browser..."
curl -L -o "$LUNA_DMG" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    print_error "Error al descargar Luna Browser"
    exit 1
fi

# Verificar el archivo descargado
if [ ! -f "$LUNA_DMG" ]; then
    print_error "No se encontró el archivo descargado"
    exit 1
fi

# Montar el DMG
print_info "Montando el instalador..."
MOUNT_POINT=$(hdiutil attach "$LUNA_DMG" | grep "/Volumes" | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    print_error "Error al montar el DMG"
    exit 1
fi

print_macos "DMG montado en: $MOUNT_POINT"

# Buscar la aplicación
APP_NAME="Luna Browser.app"
APP_PATH="$MOUNT_POINT/$APP_NAME"

if [ ! -d "$APP_PATH" ]; then
    print_error "No se encontró la aplicación en el DMG"
    hdiutil detach "$MOUNT_POINT" -force
    exit 1
fi

# Directorio de aplicaciones
APPLICATIONS_DIR="/Applications"
if [ ! -d "$APPLICATIONS_DIR" ]; then
    print_error "No se encontró el directorio de Aplicaciones"
    hdiutil detach "$MOUNT_POINT" -force
    exit 1
fi

# Verificar si ya existe una versión anterior
OLD_APP_PATH="$APPLICATIONS_DIR/$APP_NAME"
if [ -d "$OLD_APP_PATH" ]; then
    print_warning "Se encontró una versión anterior de Luna Browser"
    print_info "Eliminando versión anterior..."
    rm -rf "$OLD_APP_PATH"
fi

# Copiar la aplicación
print_info "Instalando Luna Browser en Applications..."
cp -R "$APP_PATH" "$APPLICATIONS_DIR/"

if [ $? -eq 0 ]; then
    print_message "✅ Luna Browser se ha instalado correctamente"
    
    # Desmontar el DMG
    print_info "Desmontando el instalador..."
    hdiutil detach "$MOUNT_POINT" -force
    
    # Limpiar directorio temporal
    cd /
    rm -rf "$TEMP_DIR"
    
    # Verificar instalación
    FINAL_APP_PATH="$APPLICATIONS_DIR/$APP_NAME"
    if [ -d "$FINAL_APP_PATH" ]; then
        print_macos "🎉 ¡Instalación completada!"
        print_info "Puedes iniciar Luna Browser desde Launchpad o la carpeta de Aplicaciones"
        
        # Preguntar si desea iniciar ahora
        read -p "¿Desea iniciar Luna Browser ahora? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$FINAL_APP_PATH"
        fi
        
        # Información sobre seguridad
        print_info ""
        print_warning "Nota sobre seguridad:"
        print_info "La primera vez que inicies, macOS puede mostrar un mensaje de seguridad"
        print_info "Ve a Preferencias del Sistema > Seguridad y Privacidad > General"
        print_info "y permite la ejecución de aplicaciones de 'desarrolladores no identificados'"
        
    else
        print_error "No se pudo verificar la instalación"
        exit 1
    fi
else
    print_error "Error durante la instalación"
    hdiutil detach "$MOUNT_POINT" -force
    exit 1
fi

print_macos "🌙 ¡Gracias por instalar Luna Browser!"
