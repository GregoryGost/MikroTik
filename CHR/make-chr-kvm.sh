#!/bin/bash
#
# ps.kz Ubuntu (18.06)
# CHR will automatically resize the disc
#
# !!!!!!!!!!!!!! WATCH !!!!!!!!!!!!!!!!!!!
#
# Getting Started: (commands and script mast be run from a root user only)
#
# wget https://raw.githubusercontent.com/GregoryGost/MikroTik/master/CHR/make-chr-kvm.sh
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
INTERFACE=`ip link show | grep BROADCAST | cut -d' ' -f 2 | cut -d':' -f 1` && \
ADDRESS=`ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "=== INFO ===" && \
echo "ROS: $ROS" && \
echo "USERNAME: $USERNAME" && \
echo "PASSWORD: $PASSWORD" && \
echo "INTERFACE: $INTERFACE" && \
echo "ADDRESS: $ADDRESS" && \
echo "GATEWAY: $GATEWAY" && \
echo "Generate CMD insert command" && \
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
/system reboot
 " && \
echo "=== INFO ===" && \
apt-get update && \
apt install -y wget unzip && \
sleep 5 && \
echo "Download CHR image..." && \
wget https://download.mikrotik.com/routeros/$ROS/chr-$ROS.img.zip -O chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \
sleep 5 && \
echo "Write CHR image to /dev/vda..." && \
dd if=chr.img of=/dev/vda && \
sync && \
sleep 5 && \
echo "Ok, hard reboot" && \
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
