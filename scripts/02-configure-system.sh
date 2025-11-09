#!/bin/bash

echo "Настройка системы..."

# Создание chroot скрипта для настройки
cat > $ROOTFS/setup-inside-chroot.sh << 'EOF'
#!/bin/bash

# Настройка локали
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y locales
locale-gen ru_RU.UTF-8 en_US.UTF-8
update-locale LANG=ru_RU.UTF-8

# Установка базовых пакетов
apt install -y \
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    systemd \
    dbus \
    network-manager \
    pulseaudio

# Создание пользователя
useradd -m -s /bin/bash -G sudo user
echo "user:user123" | chpasswd

# Настройка сети
echo "127.0.1.1    fist-linux" > /etc/hosts

# Установка загрузчика
apt install -y grub-efi grub-pc

EOF

# Запуск скрипта внутри chroot
chmod +x $ROOTFS/setup-inside-chroot.sh
chroot $ROOTFS /bin/bash -c "/setup-inside-chroot.sh"
rm $ROOTFS/setup-inside-chroot.sh