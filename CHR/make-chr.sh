#!/bin/bash
#
# Digital Ocean Ubuntu, Debian
#
# Running:
# wget https://raw.githubusercontent.com/GregoryGost/MikroTik/master/CHR/make-chr.sh
# chmod +x make-chr.sh
# ./make-chr.sh
#
# ROS change your version
# PASSWORD must be changes !!!
#
ROS="6.46.8"
apt-get update && \
apt install -y unzip && \
wget https://download.mikrotik.com/routeros/$ROS/chr-$ROS.img.zip -O chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \
mount -o loop,offset=33554944 chr.img /mnt && \
ADDRESS=`ip addr show eth0 | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
PASSWORD="CHANGEME" && \
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/ip service disable ftp
/ip service disable www
/ip service disable api
/ip service disable api-ssl
/user set 0 name=root password=$PASSWORD
/ip dns set servers=1.1.1.1,1.0.0.1
/system package update set channel=long-term
/system package update check-for-updates
/system package update install
 " > /mnt/rw/autorun.scr && \
umount /mnt && \
sleep 5 && \
echo u > /proc/sysrq-trigger && \
sleep 5 && \
echo "Writing raw image, this will take time" && \
dd if=chr.img bs=1024 of=/dev/vda && \
echo "Don't forget your password: $PASSWORD" && \
sleep 5 || true && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
sleep 5 || true && \
echo "Ok, reboot" && \
echo b > /proc/sysrq-trigger