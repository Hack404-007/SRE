#!/bin/bash
#
FTP_USER=webadmin
FTP_DIRECTY=/var/www/html

# Install_packet
yum install vsftpd db4 db4-devel -y
# Create File for Database User
cat > /etc/vsftpd/ftpvuser.txt <<EOF
webadmin
1q2w3e4r5t6ypwd
EOF

db_load -T -t hash -f /etc/vsftpd/ftpvuser.txt /etc/vsftpd/vu.db && chmod 600 /etc/vsftpd/vu.db
# Set Pam authenticate
mv /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
cat > /etc/pam.d/vsftpd <<EOF
auth       required    /lib64/security/pam_userdb.so     db=/etc/vsftpd/vu
account    required    /lib64/security/pam_userdb.so     db=/etc/vsftpd/vu
EOF
# Create a virtual account that corresponds to the system account
[ ! `grep admin /etc/passwd` ] && useradd -d ${FTP_DIRECTY} -s /sbin/nologin admin
mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
cat > /etc/vsftpd/vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
chroot_local_user=YES
user_config_dir=/etc/vsftpd/vuserconfig
max_clients=300
max_per_ip=10
pasv_enable=YES
pasv_min_port=10000
pasv_max_port=10004
EOF
[ ! -d /etc/vsftpd/vuserconfig ] && mkdir -pv /etc/vsftpd/vuserconfig
[ ! -f /etc/vsftpd/vuserconfig/${FTP_USER} ] && touch /etc/vsftpd/vuserconfig/${FTP_USER}
cat > /etc/vsftpd/vuserconfig/${FTP_USER} <<EOF
guest_enable=YES
guest_username=admin
anon_world_readable_only=NO
write_enable=YES
anon_mkdir_write_enable=YES
anon_upload_enable=YES
anon_max_rate=150000
anon_other_write_enable=YES
local_root=/var/www/html
chroot_local_user=YES
EOF
service vsftpd start && chkconfig vsftpd on
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
service iptables save
exit 0