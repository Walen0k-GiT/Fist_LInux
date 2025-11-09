#!/bin/bash

echo "Создание ISO образа..."

# Установка необходимых инструментов
apt install -y xorriso grub-efi-amd64-bin mtools

# Создание структуры ISO
mkdir -p $ISODIR/boot/grub

# Копирование ядра и initrd
cp $ROOTFS/boot/vmlinuz* $ISODIR/boot/vmlinuz
cp $ROOTFS/boot/initrd* $ISODIR/boot/initrd.img

# Создание конфигурации GRUB
cat > $ISODIR/boot/grub/grub.cfg << 'EOF'
set timeout=10
set default=0

menuentry "Fist Linux" {
    linux /boot/vmlinuz boot=casper quiet splash rw --
    initrd /boot/initrd.img
}

menuentry "Fist Linux (без графики)" {
    linux /boot/vmlinuz boot=casper noquiet nosplash rw --
    initrd /boot/initrd.img
}
EOF

# Создание файловой системы для ISO
cd $ROOTFS
find . -type f -print0 | xorriso -as mkisofs \
    -r -V "Fist Linux" \
    -o $OUTPUT_DIR/fist-linux-$(date +%Y%m%d).iso \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -c boot.cat \
    -b boot/grub/grub.cfg \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    ./

echo "ISO образ создан успешно!"