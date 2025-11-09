#!/bin/bash

set -e

echo "=== Fist Linux Builder ==="

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите скрипт с правами root: sudo ./build.sh"
    exit 1
fi

# Установка зависимостей
echo "Установка зависимостей..."
apt update && apt install -y debootstrap xorriso grub-efi-amd64-bin mtools squashfs-tools

# Переменные
WORKDIR="/tmp/fist-linux-build"
ISODIR="$WORKDIR/iso"
ROOTFS="$WORKDIR/rootfs"
OUTPUT_DIR="./output"

# Очистка предыдущей сборки
echo "Очистка предыдущей сборки..."
rm -rf $WORKDIR
mkdir -p $WORKDIR $ISODIR $ROOTFS $OUTPUT_DIR

# Функция очистки
cleanup() {
    echo "Очистка временных файлов..."
    umount $ROOTFS/dev 2>/dev/null || true
    umount $ROOTFS/proc 2>/dev/null || true
    umount $ROOTFS/sys 2>/dev/null || true
    rm -rf $WORKDIR
}

trap cleanup EXIT INT TERM

# Создание базовой системы
echo "Создание базовой системы Ubuntu Jammy..."
debootstrap --variant=minbase --include=locales,sudo,adduser,systemd jammy $ROOTFS http://archive.ubuntu.com/ubuntu/

# Монтирование системных директорий
echo "Монтирование системных директорий..."
mount --bind /dev $ROOTFS/dev
mount --bind /proc $ROOTFS/proc
mount --bind /sys $ROOTFS/sys

# Настройка базовой системы
echo "Настройка базовой системы..."
chroot $ROOTFS /bin/bash << 'EOL'
#!/bin/bash
set -e

# Настройка репозиториев
cat > /etc/apt/sources.list << 'EOF'
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
EOF

# Обновление пакетов
apt update

# Установка локалей
apt install -y locales
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen ru_RU.UTF-8 en_US.UTF-8
update-locale LANG=ru_RU.UTF-8

# Создание пользователя
adduser --disabled-password --gecos "" user
echo "user:user123" | chpasswd
usermod -aG sudo user

# Настройка хоста
echo "fist-linux" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.0.1.1 fist-linux" >> /etc/hosts

# Установка базовых пакетов
apt install -y \
    curl wget nano vim \
    network-manager \
    dbus systemd

echo "Базовая система настроена!"
EOL

# Установка графического окружения
echo "Установка графического окружения XFCE..."
chroot $ROOTFS /bin/bash << 'EOL'
#!/bin/bash
set -e

apt update
apt install -y \
    xorg \
    xfce4 \
    xfce4-goodies \
    lightdm \
    lightdm-gtk-greeter \
    firefox \
    thunar \
    xfce4-terminal \
    mousepad \
    gvfs \
    policykit-1 \
    dbus-x11 \
    pulseaudio

# Настройка автоматического входа
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=user
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
EOF

# Включение LightDM
systemctl enable lightdm

# Очистка кэша
apt clean
rm -rf /var/lib/apt/lists/*

echo "Графическое окружение установлено!"
EOL

# Создание ISO
echo "Создание ISO образа..."

# Размонтирование
umount $ROOTFS/dev
umount $ROOTFS/proc
umount $ROOTFS/sys

# Создание структуры ISO
mkdir -p $ISODIR/{boot/grub,live}

# Копирование ядра
KERNEL=$(ls $ROOTFS/boot/vmlinuz-* | head -1)
INITRD=$(ls $ROOTFS/boot/initrd.img-* | head -1)

if [ -f "$KERNEL" ] && [ -f "$INITRD" ]; then
    cp $KERNEL $ISODIR/live/vmlinuz
    cp $INITRD $ISODIR/live/initrd.img
else
    echo "Ошибка: Не найдены ядро или initrd"
    exit 1
fi

# Создание squashfs
echo "Создание файловой системы..."
mksquashfs $ROOTFS $ISODIR/live/filesystem.squashfs -comp xz

# Создание конфигурации GRUB
cat > $ISODIR/boot/grub/grub.cfg << 'EOF'
set timeout=10
set default=0

menuentry "Fist Linux Live" {
    linux /live/vmlinuz boot=live quiet splash --
    initrd /live/initrd.img
}

menuentry "Fist Linux Live (консоль)" {
    linux /live/vmlinuz boot=live quiet nomodeset --
    initrd /live/initrd.img
}
EOF

# Создание ISO
echo "Создание ISO файла..."
grub-mkrescue -o $OUTPUT_DIR/fist-linux-$(date +%Y%m%d).iso $ISODIR

echo "=== Сборка завершена успешно! ==="
echo "ISO файл: $OUTPUT_DIR/fist-linux-$(date +%Y%m%d).iso"