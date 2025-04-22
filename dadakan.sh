#!/bin/bash

# =============================
# Script Otomatisasi Samba Guest-Only 
# =============================

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}1. Update sistem...${NC}"
apt update && apt upgrade -y

echo -e "${GREEN}2. Install samba...${NC}"
apt install samba -y

echo -e "${GREEN}3. Buat folder share...${NC}"
mkdir -p /srv/samba/share
chmod -R 0777 /srv/samba/share
chown -R nobody:nogroup /srv/samba/share

echo -e "${GREEN}4. Backup konfigurasi Samba lama...${NC}"
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

echo -e "${GREEN}5. Tambahkan konfigurasi share guest di bawah smb.conf...${NC}"
cat <<EOL >> /etc/samba/smb.conf

[share]
   path = /srv/samba/share
   browsable = yes
   writable = yes
   guest ok = yes
   read only = no
   create mask = 0777
   directory mask = 0777
EOL

echo -e "${GREEN}6. Restart Samba...${NC}"
systemctl restart smbd

echo -e "${GREEN}7. Samba Guest sudah siap diakses! Silahkan Cek Di Windows${NC}"

