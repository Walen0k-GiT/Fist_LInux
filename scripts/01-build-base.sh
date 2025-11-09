#!/bin/bash

echo "Установка базовой системы..."

# Проверка debootstrap
if ! command -v debootstrap &> /dev/null; then
    error_exit "debootstrap не установлен. Установите зависимости сначала."
fi

# Создание базовой системы (Ubuntu 22.04 LTS)
echo "Создание базовой файловой системы..."
debootstrap --arch=amd64 jammy $ROOTFS http://archive.ubuntu.com/ubuntu/ || error_exit "Ошибка debootstrap"

# Монтирование системных директорий
echo "Монтирование системных директорий..."
mount --bind /dev $ROOTFS/dev || error_exit "Не удалось монтировать /dev"
mount --bind /proc $ROOTFS/proc || error_exit "Не удалось монтировать /proc"
mount --bind /sys $ROOTFS/sys || error_exit "Не удалось монтировать /sys"

# Копирование конфигураций
if [ -d "$CONFIG_DIR/skeleton" ]; then
    echo "Копирование skeleton файлов..."
    cp -r $CONFIG_DIR/skeleton/* $ROOTFS/ || echo "Предупреждение: Нет skeleton файлов"
fi

# Копирование скриптов в целевую систему
mkdir -p $ROOTFS/usr/local/bin
cp $CONFIG_DIR/scripts/*.sh $ROOTFS/usr/local/bin/ 2>/dev/null || true
chmod +x $ROOTFS/usr/local/bin/*.sh 2>/dev/null || true

echo "Базовая система создана успешно!"