#!/bin/bash

echo "Настройка рабочего стола..."

# Скрипт установки окружения рабочего стола
cat > $ROOTFS/setup-desktop.sh << 'EOF'
#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Установка графического окружения..."

# Обновление пакетов
apt-get update || exit 1

# Установка XFCE и зависимостей
apt-get install -y \
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
    dbus-x11 || exit 1

# Включение LightDM
systemctl enable lightdm

# Настройка автоматического входа
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'INNEREOF'
[Seat:*]
autologin-user=user
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
INNEREOF

# Создание директории для автозагрузки
mkdir -p /home/user/.config/autostart
chown -R user:user /home/user

# Создание автозагрузки для первого запуска
cat > /home/user/.config/autostart/first-boot.desktop << 'INNEREOF'
[Desktop Entry]
Type=Application
Name=First Boot Setup
Exec=/usr/local/bin/first-boot.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
INNEREOF

chown user:user /home/user/.config/autostart/first-boot.desktop

# Копирование скрипта первого запуска
cp /usr/local/bin/first-boot.sh /home/user/ || true
chmod +x /home/user/first-boot.sh || true
chown user:user /home/user/first-boot.sh || true

# Очистка
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Графическое окружение установлено!"
EOF

# Копирование скрипта первого запуска в целевую систему
mkdir -p $ROOTFS/usr/local/bin
cp config/scripts/first-boot.sh $ROOTFS/usr/local/bin/
chmod +x $ROOTFS/usr/local/bin/first-boot.sh

# Запуск скрипта в chroot
chmod +x $ROOTFS/setup-desktop.sh
chroot $ROOTFS /bin/bash -c "/setup-desktop.sh" || error_exit "Ошибка установки графического окружения"

# Удаление временного скрипта
rm -f $ROOTFS/setup-desktop.sh

echo "Настройка рабочего стола завершена!"