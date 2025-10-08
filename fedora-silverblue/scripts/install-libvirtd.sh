#! usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # https://www.mankier.com/1/gpg#Files-GNUPGHOME
    export GNUPGHOME="/tmp/.gnupg"

    dnf install --assumeyes --refresh \
    guestfs-tools \
    libguestfs \
    libguestfs-xfs \
    libvirt-client \
    libvirt-daemon \
    libvirt-daemon-config-network \
    libvirt-daemon-driver-interface \
    libvirt-daemon-driver-network \
    libvirt-daemon-driver-nodedev \
    libvirt-daemon-driver-nwfilter \
    libvirt-daemon-driver-qemu \
    libvirt-daemon-driver-secret \
    libvirt-daemon-driver-storage-core \
    libvirt-daemon-driver-storage-disk \
    libvirt-daemon-driver-storage-iscsi \
    libvirt-daemon-driver-storage-iscsi-direct \
    libvirt-daemon-driver-storage-logical \
    libvirt-daemon-driver-storage-mpath \
    libvirt-daemon-driver-storage-rbd \
    libvirt-daemon-driver-storage-scsi \
    libvirt-dbus \
    libosinfo \
    osinfo-db \
    osinfo-db-tools \
    netcat \
    qemu-img \
    qemu-kvm \
    swtpm \
    virt-install

    dnf clean all

}

main "${@}"
