#!/bin/bash

# Script para lanzar la aplicación Flutter en diferentes plataformas
# Uso: ./run.sh [chrome|macos]

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Uso:${NC} ./run.sh [PLATAFORMA]"
    echo ""
    echo -e "${BLUE}Plataformas disponibles:${NC}"
    echo "  ${GREEN}chrome${NC}  - Lanza la aplicación en Chrome (web)"
    echo "  ${GREEN}macos${NC}   - Lanza la aplicación en macOS Desktop"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  ./run.sh chrome    # Lanza en Chrome"
    echo "  ./run.sh macos     # Lanza en macOS Desktop"
    echo ""
    echo -e "${YELLOW}Nota:${NC} Si no se especifica plataforma, se usa Chrome por defecto."
}

# Obtener el directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Validar que estamos en un proyecto Flutter
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${YELLOW}Error:${NC} No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto Flutter."
    exit 1
fi

# Obtener parámetro (default: chrome)
PLATFORM=${1:-chrome}

# Normalizar parámetro a minúsculas
PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')

# Determinar dispositivo y configuración según plataforma
case "$PLATFORM" in
    chrome)
        DEVICE="chrome"
        PORT="--web-port=8080"
        echo -e "${GREEN}🌐 Lanzando aplicación en Chrome...${NC}"
        ;;
    macos)
        DEVICE="macos"
        PORT=""
        echo -e "${GREEN}🖥️  Lanzando aplicación en macOS Desktop...${NC}"
        ;;
    --help|-h|help)
        show_help
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Error:${NC} Plataforma desconocida: $PLATFORM"
        echo ""
        show_help
        exit 1
        ;;
esac

# Verificar que el dispositivo está disponible
echo -e "${BLUE}Verificando dispositivo disponible...${NC}"
AVAILABLE_DEVICES=$(flutter devices 2>/dev/null || true)
if ! echo "$AVAILABLE_DEVICES" | grep -q "$DEVICE"; then
    echo -e "${YELLOW}Advertencia:${NC} El dispositivo '$DEVICE' no está disponible."
    echo -e "${BLUE}Dispositivos disponibles:${NC}"
    echo "$AVAILABLE_DEVICES"
    exit 1
fi

# Ejecutar Flutter
echo -e "${BLUE}Ejecutando:${NC} flutter run -d $DEVICE $PORT"
echo ""

if [ "$PLATFORM" = "chrome" ]; then
    flutter run -d "$DEVICE" --web-port=8080
else
    flutter run -d "$DEVICE"
fi

