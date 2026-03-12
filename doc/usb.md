
format
```bash
sudo mkfs.ext4 /dev/sda1
```

mount
```bash
sudo mkdir /mnt/usb
lsblk -f
sudo mount /dev/sda1 /mnt/usb
sudo chown -R $USER:$USER /mnt/usb
```

clean corrupted
```bash
sudo e2fsck -fy /dev/sda1
```

copy files
```bash
rsync -rltvh --info=progress2 --no-compress --partial --inplace ~/source /mnt/usb/target
sync
```

check use
```bash
fuser -vm /mnt/usb
```

umount
```bash
sync
sudo fuser -km /mnt/usb
sudo umount /dev/sda1
```
