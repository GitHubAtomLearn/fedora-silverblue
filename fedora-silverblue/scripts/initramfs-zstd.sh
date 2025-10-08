#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    export GNUPGHOME="/tmp/.gnupg"

    # Compress the initramfs with zstd by default
    # dracut-107-6.fc43
    cd /tmp
    dnf --assumeyes install --refresh koji
    # koji download-task --arch=$(uname --machine) 2806034
    koji download-build --arch=$(uname --machine) 2806034
    # dnf --assumeyes reinstall --allowerasing dracut*.rpm
    dnf --assumeyes install --allowerasing dracut*.rpm
    # dnf --assumeyes upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-0daf9a23ee
    # rpm --query --info dracut

    export DRACUT_NO_XATTR=1
    kver=$(ls /usr/lib/modules)
    stock_arguments=$(lsinitrd "/lib/modules/${kver}/initramfs.img" |\
        grep --extended-regexp '^Arguments: ' |\
        sed 's/^Arguments: //')
    mkdir --parents /tmp/dracut /var/roothome
    # bash <(/usr/bin/echo "dracut ${stock_arguments}")
    bash <(/usr/bin/echo "dracut ${stock_arguments} --omit 'systemd-battery-check plymouth lvm mdraid'")
    mv --verbose /boot/initramfs*.img "/lib/modules/${kver}/initramfs.img"

    rm -rf /var/lib/unbound/root.key
    chmod ug-s \
        /usr/bin/chage \
        /usr/bin/chfn \
        /usr/bin/chsh \
        /usr/bin/gpasswd \
        /usr/bin/newgrp \
        /usr/bin/passwd \
        /usr/bin/vmware-user-suid-wrapper \

}

main "${@}"
