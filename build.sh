#!/bin/bash

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Fist Linux Builder ===${NC}"

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Пожалуйста, запустите скрипт с правами root: sudo ./build.sh${NC}"
    exit 1
fi

# Переменные
WORKDIR="/tmp/fist-linux-build"
ISODIR="$WORKDIR/iso"
ROOTFS="$WORKDIR/rootfs"
CONFIG_DIR="./config"
SCRIPTS_DIR="./scripts"
OUTPUT_DIR="./output"

# Создание рабочих директорий
mkdir -p $WORKDIR $ISODIR $ROOTFS $OUTPUT_DIR

# Функции
cleanup() {
    echo -e "${YELLOW}Очистка временных файлов...${NC}"
    rm -rf $WORKDIR
}

error_exit() {
    echo -e "${RED}Ошибка: $1${NC}"
    cleanup
    exit 1
}

# Обработка прерывания
trap cleanup EXIT INT TERM

# Основной процесс сборки
echo -e "${GREEN}Этап 1: Подготовка окружения${NC}"
source $SCRIPTS_DIR/01-build-base.sh

echo -e "${GREEN}Этап 2: Настройка системы${NC}"
source $SCRIPTS_DIR/02-configure-system.sh

echo -e "${GREEN}Этап 3: Настройка рабочего стола${NC}"
source $SCRIPTS_DIR/03-customize-desktop.sh

echo -e "${GREEN}Этап 4: Создание ISO${NC}"
source $SCRIPTS_DIR/04-create-iso.sh

echo -e "${GREEN}=== Сборка завершена успешно! ===${NC}"
echo -e "${GREEN}ISO файл: $OUTPUT_DIR/fist-linux-$(date +%Y%m%d).iso${NC}"