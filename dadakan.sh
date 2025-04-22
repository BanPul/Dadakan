#!/bin/bash

# ===============================================
# Otomatisasi Samba Guest dengan alur: 
# Repo Bawaan → Install Samba → Ganti ke Kartolo
# ===============================================

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}1. Update repo bawaan Ubuntu...${NC}"
apt update

echo -e "${GREEN}2. Install Samba dulu sebelum ganti repo...${NC}"
dpkg -l | grep -q samba || apt install samba -y

echo -e "${GREEN}3. Ganti repo ke Kartolo dan proposed...${NC}"
# Backup dulu repo lama kalau belum ada backup
[ -f /etc/apt/sources.list.bak ] || cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Hapus baris repo lain agar bersih
sed -i '/^deb /d' /etc/apt/sources.list

# Tambahkan repo Kartolo
cat <<EOF >> /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu focal-proposed main restricted universe multiverse
EOF

echo -e "${GREEN}4. Update ulang dengan repo Kartolo...${NC}"
apt update

echo -e "${GREEN}5. Buat folder share jika belum ada...${NC}"
[ -d /srv/samba/share ] || mkdir -p /srv/samba/share
chmod -R 0777 /srv/samba/share
chown -R nobody:nogroup /srv/samba/share

echo -e "${GREEN}6. Backup konfigurasi Samba jika belum ada...${NC}"
[ -f /etc/samba/smb.conf.bak ] || cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

echo -e "${GREEN}7. Tambahkan konfigurasi guest Samba jika belum ada...${NC}"
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

echo -e "${GREEN}8. Restart layanan Samba...${NC}"
systemctl restart smbd

echo -e "${GREEN}9. Samba Guest siap digunakan di Windows!${NC}"
echo -e "${GREEN}   Buka: \\\\$(hostname -I | awk '{print $1}')\\share${NC}"
