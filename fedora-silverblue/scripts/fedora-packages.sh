#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # https://www.mankier.com/1/gpg#Files-GNUPGHOME
    export GNUPGHOME="/tmp/.gnupg"

    # dnf -y upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-01e5d62106
    
    # dnf install -y https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2025.7/3.fc42/x86_64/rpm-ostree-2025.7-3.fc42.x86_64.rpm \
    #     https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2025.7/3.fc42/x86_64/rpm-ostree-libs-2025.7-3.fc42.x86_64.rpm

    # rust-bootupd-0.2.31-1.fc43
    # dnf --assumeyes upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-b163a3c238

    # f43-backgrounds-43.0.3-1.fc43
    # dnf --assumeyes upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-a1c2efd124
    # dnf --assumeyes install --refresh koji
    # cd /tmp
    # koji download-build 2817832
    # dnf --assumeyes install --allowerasing \
    # f43-backgrounds-base-43.0.3-1.fc43.noarch.rpm \
    # f43-backgrounds-gnome-43.0.3-1.fc43.noarch.rpm

    # ostree-2025.6-1.fc43
    # dnf --assumeyes install --refresh koji
    # cd /tmp
    # koji download-build --arch=$(uname --machine) 2806116
    # dnf --assumeyes install --allowerasing ostree*.rpm
    # dnf --assumeyes upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-bfca270bb0
    # rpm --query --info ostree

    # rpm-ostree-2025.11-1.fc43
    # dnf --assumeyes upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-f2c9894404

    # bootc-1.8.0-1.fc43
    # koji download-build --arch=$(uname --machine) 2804089
    # dnf --assumeyes install --allowerasing bootc*.rpm system-reinstall-bootc*.rpm
    # dnf --assumeyes upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-ee69e8cf3b
    
    # krb5-1.21.3-7.fc43
    # dnf --assumeyes install --refresh koji
    # cd /tmp
    # koji download-build --arch=$(uname --machine) 2760592
    # koji download-build --arch=$(arch) 2760592
    # dnf --assumeyes install --allowerasing *.rpm

    dnf swap --assumeyes --refresh --allowerasing nano vim-default-editor
    dnf swap --assumeyes --refresh --allowerasing noopenh264 mozilla-openh264

    # dnf -y remove --no-autoremove --noautoremove $(grep -Ev '^#|^$' /tmp/remove-fedora-packages.txt)
    dnf remove --assumeyes --refresh $(grep --extended-regexp --invert-match '^#|^$' /tmp/scripts/remove-fedora-packages.txt)
    # dnf -y remove --no-autoremove --noautoremove plymouth
    # dnf -y remove --no-autoremove --noautoremove yelp
    # dnf -y remove --no-autoremove --noautoremove gnome-tour
    # dnf -y remove --no-autoremove --noautoremove malcontent
    # rpm --erase --nodeps $(grep -Ev '^#|^$' /tmp/remove-fedora-packages.txt)
    # rpm -qa | grep malcontent
    rpm --erase --nodeps malcontent
    rpm --erase --nodeps malcontent-control
    rpm --erase --nodeps malcontent-ui-libs
    # rpm --erase --nodeps malcontent-libs
    # rpm -qa | grep malcontent

    dnf install --assumeyes --refresh --allowerasing $(grep -Ev '^#|^$' /tmp/scripts/install-fedora-packages.txt)

    # systemctl enable libvirtd.socket
    # systemctl enable virtqemud.socket virtnetworkd.socket virtstoraged.socket \
    # rm-mount-for-root-from-etc-fstab.service
    # systemctl enable rm-mount-for-root-from-etc-fstab.service

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
