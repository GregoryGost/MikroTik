#!/bin/bash
#
# Digital Ocean Ubuntu, Debian (10,11)
# CHR will automatically resize the disc
#
# !!!!!!!!!!!!!! WATCH !!!!!!!!!!!!!!!!!!!
#
# Getting Started: (commands and script mast be run from a root user only)
# mount -t tmpfs tmpfs /tmp/
# cd /tmp
# wget https://github.com/GregoryGost/MikroTik/raw/master/CHR/make-chr.sh
#
# chmod +x make-chr.sh
# ./make-chr.sh 6.48.6 admin admin
#
if [ -z $1 ]; then
	echo 'Specify version of RouterOS!'
	exit;
fi
if [ -z $2 ]; then
	echo 'Specify RoS admin name!'
	exit;
fi
if [ -z $3 ]; then
	echo 'Specify RoS admin password!'
	exit;
fi
ROS="$1" && \
USERNAME="$2" && \
PASSWORD="$3" && \
echo "ROS: $ROS" && \
echo "USERNAME: $USERNAME" && \
echo "PASSWORD: $PASSWORD" && \
apt-get update && \
apt install -y wget unzip qemu-utils parted psmisc && \
sleep 5 && \
echo "Go to root dir..." && \
cd /root &&\
echo "Download CHR image..." && \
wget https://download.mikrotik.com/routeros/$ROS/chr-$ROS.img.zip -O chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \
sleep 5 && \
echo "Convert CHR image..." && \
qemu-img convert chr.img -O qcow2 chr.qcow2  && \
echo "Move chr.qcow2 to tmp dir..." && \
mv chr.qcow2 /tmp && \
echo "Go to tmp dir..." && \
cd /tmp
modprobe nbd  && \
qemu-nbd -c /dev/nbd0 chr.qcow2  && \
sleep 5 && \
partprobe /dev/nbd0 && \
sleep 5 && \
echo "Mount CHR image..." && \
mount /dev/nbd0p1 /mnt && \
INTERFACE=`ip link show | grep BROADCAST | cut -d' ' -f 2 | cut -d':' -f 1` && \
ADDRESS=`ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
/ip service disable telnet
/ip service disable ftp
/ip service disable www
/ip service disable api
/ip service disable api-ssl
/user add name=$USERNAME group=full password=$PASSWORD disabled=no
/user set admin disabled=yes
/ip dns set servers=1.1.1.1,1.0.0.1
/system package update set channel=long-term
/system package update check-for-updates
/system package update install
 " > /mnt/rw/autorun.scr && \
sleep 5 && \
echo "Unmount CHR image..." && \
umount /mnt && \
sleep 5 && \
echo "Write CHR image to /dev/vda..." && \
dd if=/dev/nbd0 of=/dev/vda bs=4M oflag=sync && \
sleep 5 && \
killall qemu-nbd && \
sleep 5 && \
echo "Ok, hard reboot" && \
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger