#!/bin/bash

echo "Настройка рабочего стола..."

# Скрипт установки окружения рабочего стола
cat > $ROOTFS/setup-desktop.sh << 'EOF'
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Установка XFCE (легковесное окружение)
apt install -y \
    xorg \
    xfce4 \
    xfce4-goodies \
    lightdm \
    lightdm-gtk-greeter \
    firefox \
    file-manager \
    gedit \
    terminal \
    synaptic

# Автоматический вход
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'INNEREOF'
[Seat:*]
autologin-user=user
autologin-user-timeout=0
user-session=xfce
INNEREOF

# Настройка автоматического запуска приложений
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/first-boot.desktop << 'INNEREOF'
[Desktop Entry]
Type=Application
Name=First Boot Setup
Exec=/usr/local/bin/first-boot.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
INNEREOF

EOF

# Копирование наших overlay файлов
if [ -d "./overlays" ]; then
    cp -r ./overlays/* $ROOTFS/
fi

chmod +x $ROOTFS/setup-desktop.sh
chroot $ROOTFS /bin/bash -c "/setup-desktop.sh"
rm $ROOTFS/setup-desktop.sh