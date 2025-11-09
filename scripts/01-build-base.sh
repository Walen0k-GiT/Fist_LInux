#!/bin/bash

echo "Установка базовой системы..."

# Установка debootstrap если не установлен
if ! command -v debootstrap &> /dev/null; then
    apt update && apt install -y debootstrap
fi

# Создание базовой системы (Ubuntu 22.04 LTS)
debootstrap jammy $ROOTFS http://archive.ubuntu.com/ubuntu/ || error_exit "Ошибка debootstrap"

# Монтирование системных директорий
mount --bind /dev $ROOTFS/dev
mount --bind /proc $ROOTFS/proc
mount --bind /sys $ROOTFS/sys

# Копирование конфигураций
cp -r $CONFIG_DIR/skeleton/* $ROOTFS/ || echo "Предупреждение: Нет skeleton файлов"