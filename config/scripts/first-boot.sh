#!/bin/bash
# first-boot.sh - скрипт первого запуска Fist Linux

echo "Настройка Fist Linux при первом запуске..."

# Ожидание загрузки графической среды
sleep 10

# Создание ярлыков на рабочем столе
mkdir -p /home/user/Desktop

# Ярлык Firefox
cat > /home/user/Desktop/firefox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Веб-браузер
Exec=firefox
Icon=firefox
Terminal=false
Categories=Network;WebBrowser;
EOF

# Ярлык терминала
cat > /home/user/Desktop/terminal.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Терминал
Comment=Командная строка
Exec=xfce4-terminal
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF

# Ярлык файлового менеджера
cat > /home/user/Desktop/files.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Файлы
Comment=Файловый менеджер
Exec=thunar
Icon=system-file-manager
Terminal=false
Categories=System;FileManager;
EOF

chmod +x /home/user/Desktop/*.desktop
chown -R user:user /home/user/Desktop

# Установка обновлений в фоне
echo "Проверка обновлений..."
sudo apt update > /tmp/update.log 2>&1 &

# Уведомление
notify-send "Добро пожаловать в Fist Linux!" "Система готова к использованию."

echo "Настройка завершена!"