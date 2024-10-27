#!/bin/bash
#
# CHR will automatically resize the disc
#
# !!!!!!!!!!!!!! WATCH !!!!!!!!!!!!!!!!!!!
#
# Getting Started: (commands and script mast be run from a root user only)
# sudo su - root
# wget https://raw.githubusercontent.com/GregoryGost/MikroTik/refs/heads/master/CHR/make-chr.sh
#
# chmod +x make-chr.sh
# ./make-chr.sh 7.16.1
#
if [ -z $1 ]; then
	echo 'Specify version of RouterOS!'
	exit;
fi
if [[ "$(mount | grep ' / ' | awk '{ print $1 }')" =~ ^/dev/mapper ]]; then
  DEVICE=$(findmnt -n -o SOURCE / | xargs -I{} dmsetup info -c {} | awk '$1 == "Name" {print $NF}' | xargs -I{} lsblk -np -o NAME,MOUNTPOINT | awk '/^\/dev\/sd/')
else
  DEVICE=$(lsblk -o PKNAME,NAME,MOUNTPOINT | grep $(findmnt -n -o SOURCE /) | awk '{print $1}')
fi
#
ROS="$1" && \
INTERFACE=`ip link show | grep BROADCAST | cut -d' ' -f 2 | cut -d':' -f 1` && \
ADDRESS=`ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1` && \
GATEWAY=`ip route list | grep default | cut -d' ' -f 3` && \
echo "=== INFO ===" && \
echo "DEVICE: $DEVICE" && \
echo "ROS: $ROS" && \
echo "INTERFACE: $INTERFACE" && \
echo "ADDRESS: $ADDRESS" && \
echo "GATEWAY: $GATEWAY" && \
echo "=== INFO ==="
#
echo "Please save the information from the INFO block !!! And press any key."
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
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
