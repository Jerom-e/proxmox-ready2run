#!/bin/sh
# Variables communes
TEMPLATE_DIR="/root/cloud-version"
STORAGE_POOL="local-lvm"
BRIDGE="vmbr0"
CORES=2
MEMORY=2048
DISK_SIZE="25G"
CLOUDINIT_DISK="${STORAGE_POOL}:cloudinit"
# Création de répertoires et de l'arborescence de travail
mkdir -p "$TEMPLATE_DIR"
cd "$TEMPLATE_DIR"
# Fonction pour créer un template
create_template() {
    local id=$1
    local name=$2
    local url=$3
    local img_file=$(basename "$url")
    echo "Création du template $name"
    mkdir -p "$name"
    cd "$name"
    wget "$url"
    qm create "$id" --name "$name" --net0 virtio,bridge="$BRIDGE" --scsihw virtio-scsi-single
    qm set "$id" --scsi0 "${STORAGE_POOL}:0,iothread=1,backup=off,format=qcow2,import-from=${TEMPLATE_DIR}/${name}/${img_file}"
    qm disk resize "$id" scsi0 "$DISK_SIZE"
    qm set "$id" --boot order=scsi0
    qm set "$id" --cpu host --cores "$CORES" --memory "$MEMORY"
    qm set "$id" --ide2 "$CLOUDINIT_DISK"
    qm set "$id" --tags "templates"
    qm set "$id" --agent enabled=1
    qm template "$id"
    cd ..
    echo "Fin de création du template $name"
}

# Templates 
# create_template 9001 "template-ubuntu-18" "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
# create_template 9002 "template-ubuntu-20" "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
# create_template 9003 "template-ubuntu-22" "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
# create_template 9004 "template-ubuntu-24" "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
create_template 9005 "template-debian-13" "https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-generic-amd64-daily.qcow2"
# create_template 9006 "template-debian-10" "https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2"
# create_template 9007 "template-debian-11" "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
# create_template 9008 "template-debian-12" "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
# create_template 9009 "template-alma-8" "https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-8.10-20240819.x86_64.qcow2"
create_template 9010 "template-alma-9" "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
# create_template 9011 "template-amazon-23" "https://cdn.amazonlinux.com/al2023/os-images/2023.7.20250512.0/kvm/al2023-kvm-2023.7.20250512.0-kernel-6.1-x86_64.xfs.gpt.qcow2"


# PoOlS
pvesh create /pools --poolid zone-templates --comment "debian12 & amazon 2023"
# pvesh create /pools --poolid zone-kubernetes --comment "Reverse, Proxy & Load Balancing"
# pvesh create /pools --poolid zone-application --comment "EDR,ELK,Supervision,Gitlab"

pvesh set /pools/zone-templates --vm 9005
pvesh set /pools/zone-templates --vm 9010

echo "Fin de création du paramétrage de bases de  proxmox"

