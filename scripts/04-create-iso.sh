#!/bin/bash

echo "Создание ISO образа..."

# Размонтирование системных директорий
umount $ROOTFS/dev 2>/dev/null || true
umount $ROOTFS/proc 2>/dev/null || true
umount $ROOTFS/sys 2>/dev/null || true

# Создание структуры ISO
mkdir -p $ISODIR/{boot/grub,live}

# Копирование ядра
KERNEL=$(ls $ROOTFS/boot/vmlinuz-* | head -1)
INITRD=$(ls $ROOTFS/boot/initrd.img-* | head -1)

if [ -f "$KERNEL" ] && [ -f "$INITRD" ]; then
    cp $KERNEL $ISODIR/live/vmlinuz
    cp $INITRD $ISODIR/live/initrd.img
else
    error_exit "Не найдены ядро или initrd"
fi

# Создание squashfs
echo "Создание squashfs файловой системы..."
mksquashfs $ROOTFS $ISODIR/live/filesystem.squashfs -comp xz || error_exit "Ошибка создания squashfs"

# Создание конфигурации GRUB
cat > $ISODIR/boot/grub/grub.cfg << 'EOF'
set timeout=10
set default=0

menuentry "Fist Linux Live" {
    linux /live/vmlinuz boot=live quiet splash --
    initrd /live/initrd.img
}

menuentry "Fist Linux Live (без графики)" {
    linux /live/vmlinuz boot=live quiet nomodeset --
    initrd /live/initrd.img
}
EOF

# Создание ISO
echo "Создание ISO файла..."
grub-mkrescue -o $OUTPUT_DIR/fist-linux-$(date +%Y%m%d).iso $ISODIR || error_exit "Ошибка создания ISO"

echo "ISO образ создан успешно!"