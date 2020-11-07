#!/bin/bash
#
# Digital Ocean Ubuntu, Debian
#
# Running:
# wget https://github.com/GregoryGost/MikroTik/raw/master/CHR/make-chr.sh
# chmod +x make-chr.sh
# ./make-chr.sh
#
# ROS change your version
# PASSWORD must be changes !!!
#
ROS="6.46.8" && \
PASSWORD="CHANGEME" && \
apt-get update && \
apt install -y unzip qemu-utils pv && \
mount -t tmpfs tmpfs /tmp/ && \
cd /tmp
wget https://download.mikrotik.com/routeros/$ROS/chr-$ROS.img.zip -O chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \
qemu-img convert chr.img -O qcow2 chr.qcow2  && \
modprobe nbd  && \
qemu-nbd -c /dev/nbd0 chr.qcow2  && \
sleep 5 && \
partprobe /dev/nbd0 && \
sleep 5 && \
mount /dev/nbd0p1 /mnt && \
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
dd if=/dev/nbd0 of=/dev/vda bs=4M oflag=sync && \
sleep 5 && \
killall qemu-nbd && \
sleep 5 && \
echo "Ok, hard reboot" && \
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger