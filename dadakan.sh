#!/bin/bash

# =============================
# Otomatisasi Samba Guest-Only (Ubuntu 20.04)
# Dengan Repo Kartolo & Proteksi Duplikasi
# =============================

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}1. Install samba terlebih dahulu...${NC}"
dpkg -l | grep -q samba || apt install samba -y

echo -e "${GREEN}2. Tambahkan repository Kartolo dan proposed jika belum ada...${NC}"
# Tambah Kartolo hanya jika belum ada
grep -q "kartolo" /etc/apt/sources.list || echo "deb http://kartolo.sby.datautama.net.id/ubuntu focal main restricted universe multiverse" >> /etc/apt/sources.list
# Tambah proposed hanya jika belum ada
grep -q "focal-proposed" /etc/apt/sources.list || echo "deb http://kartolo.sby.datautama.net.id/ubuntu focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list

echo -e "${GREEN}3. Update repository...${NC}"
apt update

echo -e "${GREEN}4. Buat folder share jika belum ada...${NC}"
[ -d /srv/samba/share ] || mkdir -p /srv/samba/share
chmod -R 0777 /srv/samba/share
chown -R nobody:nogroup /srv/samba/share

echo -e "${GREEN}5. Backup konfigurasi Samba jika belum ada backup...${NC}"
[ -f /etc/samba/smb.conf.bak ] || cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

echo -e "${GREEN}6. Cek dan tambahkan konfigurasi guest Samba jika belum ada...${NC}"
# Cek dan tambahkan konfigurasi guest jika belum ada
if ! grep -q "\[share\]" /etc/samba/smb.conf; then
cat <<EOL >> /etc/samba/smb.conf

[global]
   workgroup = WORKGROUP
   server string = Samba Guest Server
   map to guest = Bad User
   guest account = nobody
   dns proxy = no

[share]
   path = /srv/samba/share
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
   create mask = 0777
   directory mask = 0777
EOL
fi

echo -e "${GREEN}7. Restart layanan Samba...${NC}"
systemctl restart smbd

echo -e "${GREEN}8. Menahan paket samba agar tidak auto update...${NC}"
apt-mark hold samba smbclient samba-common samba-common-bin

echo -e "${GREEN}9. Samba Guest siap digunakan di Windows!${NC}"
echo -e "${GREEN}   Buka: \\\\$(hostname -I | awk '{print $1}')\\share${NC}"
