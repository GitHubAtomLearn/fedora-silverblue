#! usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # https://www.mankier.com/1/gpg#Files-GNUPGHOME
    export GNUPGHOME="/tmp/.gnupg"

    # dnf -y upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-96e470a839
    
    dnf install -y https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2025.7/3.fc42/x86_64/rpm-ostree-2025.7-3.fc42.x86_64.rpm \
        https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2025.7/3.fc42/x86_64/rpm-ostree-libs-2025.7-3.fc42.x86_64.rpm

    dnf -y remove plymouth plymouth-core-libs plymouth-graphic-libs
    dnf swap -y --allowerasing nano vim-default-editor
    dnf swap -y --allowerasing noopenh264 mozilla-openh264

    dnf -y install $(grep -Ev '^#|^$' /tmp/packages.txt)

    systemctl enable virtqemud.socket virtnetworkd.socket virtstoraged.socket \
    rm-mount-for-root-from-etc-fstab.service
#    systemctl enable libvirtd.socket

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
