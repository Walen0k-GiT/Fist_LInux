#!/bin/bash

echo "Настройка системы..."

# Создание chroot скрипта для настройки
cat > $ROOTFS/setup-inside-chroot.sh << 'EOF'
#!/bin/bash

set -e

echo "Настройка внутри chroot..."

# Настройка apt источников
cat > /etc/apt/sources.list << 'SOURCESEOF'
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
SOURCESEOF

# Настройка локали
export DEBIAN_FRONTEND=noninteractive
apt-get update || exit 1

# Установка базовых системных утилит В ПЕРВУЮ ОЧЕРЕДЬ
apt-get install -y \
    locales \
    adduser \
    passwd \
    sudo \
    systemd \
    dbus || exit 1

# Генерация локалей
echo "Генерация локалей..."
locale-gen ru_RU.UTF-8 en_US.UTF-8
update-locale LANG=ru_RU.UTF-8 LC_ALL=ru_RU.UTF-8

# Создание пользователя
echo "Создание пользователя..."
adduser --disabled-password --gecos "" user || true
echo "user:user123" | chpasswd
usermod -aG sudo user

# Настройка хоста
echo "fist-linux" > /etc/hostname
echo "127.0.0.1    localhost" > /etc/hosts
echo "127.0.1.1    fist-linux" >> /etc/hosts

# Настройка sudo
echo "user ALL=(ALL) ALL" >> /etc/sudoers
echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/user
chmod 440 /etc/sudoers.d/user

# Установка остальных базовых пакетов
apt-get install -y \
    curl \
    wget \
    git \
    nano \
    vim \
    network-manager \
    pulseaudio || exit 1

# Очистка
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Настройка внутри chroot завершена!"
EOF

# Запуск скрипта внутри chroot
chmod +x $ROOTFS/setup-inside-chroot.sh
echo "Запуск настройки в chroot..."
chroot $ROOTFS /bin/bash -c "/setup-inside-chroot.sh" || error_exit "Ошибка в chroot"

# Удаление временного скрипта
rm -f $ROOTFS/setup-inside-chroot.sh

echo "Настройка системы завершена!"