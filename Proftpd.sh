#!/bin/bash

# Fedora ProFTPD setup script
# Shared FTP directory: /home/admin/Shared
# FTP user: ftpuser

FTP_USER="ftpuser"
FTP_DIR="/home/admin/Shared"
PASSIVE_START=30000
PASSIVE_END=30100

echo "Updating system..."
sudo dnf update -y

echo "Installing packages..."
sudo dnf install -y proftpd proftpd-utils firewalld policycoreutils-python-utils

echo "Creating shared directory..."
sudo mkdir -p "$FTP_DIR"

echo "Creating FTP user..."
if id "$FTP_USER" &>/dev/null; then
    echo "User already exists."
else
    sudo useradd -d "$FTP_DIR" "$FTP_USER"
    sudo passwd "$FTP_USER"
fi

echo "Setting shell to nologin..."
sudo usermod -s /sbin/nologin "$FTP_USER"

echo "/sbin/nologin" | sudo tee -a /etc/shells

echo "Setting permissions..."
sudo chown -R "$FTP_USER:$FTP_USER" "$FTP_DIR"
sudo chmod -R 755 "$FTP_DIR"

echo "Backing up ProFTPD config..."
sudo cp /etc/proftpd.conf /etc/proftpd.conf.bak

echo "Writing ProFTPD configuration..."

sudo tee /etc/proftpd.conf > /dev/null <<EOF
ServerName                      "Fedora FTP Server"
ServerType                      standalone
DefaultServer                   on

Port                            21
Umask                           022

MaxInstances                    30

User                            nobody
Group                           nobody

RequireValidShell               off

DefaultRoot                     $FTP_DIR

PassivePorts                    $PASSIVE_START $PASSIVE_END

SystemLog                       /var/log/proftpd/proftpd.log
TransferLog                     /var/log/proftpd/xferlog

<Directory $FTP_DIR>
    AllowOverwrite              on

    <Limit ALL>
        AllowAll
    </Limit>
</Directory>
EOF

echo "Configuring SELinux..."

sudo setsebool -P ftp_home_dir=1
sudo setsebool -P ftpd_full_access=1
sudo setsebool -P ftpd_use_passive_mode=1

sudo semanage fcontext -a -t public_content_rw_t "${FTP_DIR}(/.*)?"
sudo restorecon -Rv "$FTP_DIR"

echo "Configuring firewall..."

sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=${PASSIVE_START}-${PASSIVE_END}/tcp
sudo firewall-cmd --reload

echo "Enabling and restarting ProFTPD..."

sudo systemctl enable --now proftpd
sudo systemctl restart proftpd

echo "Testing ProFTPD configuration..."
sudo proftpd -t

echo ""
echo "======================================="
echo " ProFTPD setup completed"
echo " FTP User : $FTP_USER"
echo " Shared Dir: $FTP_DIR"
echo "======================================="
echo ""
echo "Connect using:"
echo "ftp <SERVER_IP>"