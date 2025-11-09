#!/bin/bash

# Скрипт первого запуска
echo "Настройка Fist Linux при первом запуске..."

# Настройка региона
timedatectl set-timezone Europe/Moscow

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка дополнительного ПО
sudo apt install -y \
    gparted \
    vlc \
    gimp \
    libreoffice

# Настройка внешнего вида (Windows-like)
xfconf-query -c xsettings -p /Net/ThemeName -s "Windows-10"
xfconf-query -c xfwm4 -p /general/theme -s "Windows-10"

echo "Настройка завершена!"
notify-send "Fist Linux" "Система готова к использованию!"