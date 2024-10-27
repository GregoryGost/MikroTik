#!/bin/bash
#
# CHR will automatically resize the disc
#
# !!!!!!!!!!!!!! WATCH !!!!!!!!!!!!!!!!!!!
#
# Getting Started: (commands and script mast be run from a root user only)
# sudo su - root
# curl -O https://raw.githubusercontent.com/GregoryGost/MikroTik/refs/heads/master/CHR/make-chr.sh
# chmod +x make-chr.sh
# ./make-chr.sh 7.16.1
#
if [ -z $1 ]; then
	echo 'Specify version of RouterOS!'
	exit;
fi
apt-get update && \
apt install -y funzip
if [[ "$(mount | grep ' / ' | awk '{ print $1 }')" =~ ^/dev/mapper ]]; then
  DEVICE=$(findmnt -n -o SOURCE / | xargs -I{} dmsetup info -c {} | awk '$1 == "Name" {print $NF}' | xargs -I{} lsblk -np -o NAME,MOUNTPOINT | awk '/^\/dev\/sd/')
else
  DEVICE=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
fi
#
ROS="$1" && \
INTERFACE=`ip link show | grep BROADCAST | cut -d' ' -f 2 | cut -d':' -f 1` && \
ADDRESS=`ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "=== INFO ===" && \
echo "VPS ROOT DEVICE: $DEVICE" && \
echo "ROS VERSION: $ROS" && \
echo "UBUNTU INTERFACE: $INTERFACE" && \
echo "=== /INFO ===" && \
echo "=== SAVE INFO ===" && \
echo "VPS IPv4 ADDRESS: $ADDRESS" && \
echo "VPS GATEWAY: $GATEWAY" && \
echo "=== /SAVE INFO ==="
#
echo "Please save the information from the SAVE INFO block !!! And press any key."
while true; do
  read -rsn1 key
  if [[ -n "$key" ]]; then
    break
  fi
done
#
echo "Write CHR image to $DEVICE..." && \
curl -L https://download.mikrotik.com/routeros/$ROS/chr-$ROS.img.zip | funzip | dd of=$DEVICE bs=1M
sleep 5 && \
echo "Ok, hard reboot" && \
echo 1 > /proc/sys/kernel/sysrq && \
echo b > /proc/sysrq-trigger
