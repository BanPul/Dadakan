#!/bin/bash

# Nama share dan direktori
SHARE_NAME="public"
SHARE_DIR="/srv/samba/$SHARE_NAME"

# 1. Install samba (jika belum)
sudo apt-get update
sudo apt-get install -y samba

# 2. Buat direktori untuk sharing
sudo mkdir -p "$SHARE_DIR"
sudo chown nobody:nogroup "$SHARE_DIR"
sudo chmod 0775 "$SHARE_DIR"

# 3. Backup dan edit konfigurasi samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# 4. Tambahkan konfigurasi share baru
sudo bash -c "cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
   path = $SHARE_DIR
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
EOF"

# 5. Restart layanan Samba
sudo systemctl restart smbd

echo "Samba public share '$SHARE_NAME' telah berhasil dibuat dan bisa diakses tanpa login."
