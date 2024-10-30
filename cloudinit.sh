#!/bin/bash


IMAGE_PATH=$1

# Get the highest VM id 
ID=$(qm list | awk '{ print $1 }' | sort -r | head -n 2 | tail -n 1)
ID=$((ID+1))

# Check the number of arguments
if [[ $# -ne 1 ]]
then
  echo "Usage: $0 <image path>"
  exit 1
fi

#Check whether the image exists
if [[ ! -f $IMAGE_PATH ]]
then
  echo "The image $IMAGE_PATH does not exist"
  exit 1
fi

apt update -y && apt install -y libguestfs-tools -y

virt-customize -a $IMAGE_PATH --install qemu-guest-agent
#virt-customize -a $IMAGE_PATH --run-command 'systemctl enable qemu-guest-agent.service'
#virt-customize -a $IMAGE_PATH --run-command 'systemctl mask systemd-networkd-wait-online.service'


qm create $ID --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci

qm set $ID --scsi0 local-lvm:0,import-from=$IMAGE_PATH

qm set $ID --ide2 local-lvm:cloudinit
qm set $ID --serial0 socket --vga serial0

qm set $ID --boot order=scsi0

qm template $ID

