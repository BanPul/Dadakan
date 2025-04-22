#!/bin/bash

# ===============================================
# Otomatisasi Konfigurasi Samba Guest + Repo Kartolo Lengkap
# Untuk Ubuntu 20.04 (Focal)
# ===============================================

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}1. Menulis ulang repo Ubuntu ke mirror Kartolo...${NC}"
cat <<EOF > /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-proposed main restricted universe multiverse
EOF

echo -e "${GREEN}2. Update dan upgrade sistem...${NC}"
apt update && apt upgrade -y

echo -e "${GREEN}3. Install Samba...${NC}"
apt-get install samba -y

echo -e "${GREEN}4. Buat folder share guest...${NC}"
mkdir -p /srv/samba/share
chmod -R 0777 /srv/samba/share
chown -R nobody:nogroup /srv/samba/share

echo -e "${GREEN}5. Backup konfigurasi Samba lama...${NC}"
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

echo -e "${GREEN}6. Tambahkan konfigurasi guest share ke smb.conf...${NC}"
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

echo -e "${GREEN}7. Restart Samba...${NC}"
systemctl restart smbd

echo -e "${GREEN}8. Samba Guest siap diakses!${NC}"
echo -e "${GREEN}   Dari Windows: \\\\$(hostname -I | awk '{print $1}')\\share${NC}"
