#!/bin/bash

# 1. Instalasi Samba
sudo apt-get update
sudo apt-get install -y samba

# 2. Edit File Konfigurasi Samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Tambahkan konfigurasi global untuk guest access
sudo sed -i '/^\[global\]/a \
   map to guest = Bad User\n\
   guest account = nobody' /etc/samba/smb.conf

# Tambahkan konfigurasi share
sudo bash -c "cat >> /etc/samba/smb.conf <<EOF

[share]
   path = /srv/samba/share
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
EOF"

# 3. Buat Direktori Berbagi
sudo mkdir -p /srv/samba/share
sudo chown nobody:nogroup /srv/samba/share
sudo chmod 0775 /srv/samba/share

# 4. Restart Samba
sudo systemctl restart smbd

echo "Share 'share' berhasil dibuat dan bisa diakses sebagai guest tanpa password."
