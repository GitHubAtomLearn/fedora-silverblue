#! usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # https://www.mankier.com/1/gpg#Files-GNUPGHOME
    export GNUPGHOME="/tmp/.gnupg"

    # dnf -y upgrade --enablerepo=updates-testing --refresh --advisory=FEDORA-2025-01e5d62106
    
    # dnf install -y https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2025.7/3.fc42/x86_64/rpm-ostree-2025.7-3.fc42.x86_64.rpm \
    #     https://kojipkgs.fedoraproject.org//packages/rpm-ostree/2025.7/3.fc42/x86_64/rpm-ostree-libs-2025.7-3.fc42.x86_64.rpm

    dnf swap -y --allowerasing nano vim-default-editor
    dnf swap -y --allowerasing noopenh264 mozilla-openh264

    # dnf -y remove --no-autoremove --noautoremove $(grep -Ev '^#|^$' /tmp/remove_fedora_packages.txt)
    dnf -y remove $(grep --extended-regexp --invert-match '^#|^$' /tmp/remove_fedora_packages.txt)
    # dnf -y remove --no-autoremove --noautoremove plymouth
    # dnf -y remove --no-autoremove --noautoremove yelp
    # dnf -y remove --no-autoremove --noautoremove gnome-tour
    # dnf -y remove --no-autoremove --noautoremove malcontent
    # rpm --erase --nodeps $(grep -Ev '^#|^$' /tmp/remove_fedora_packages.txt)
    # rpm -qa | grep malcontent
    rpm --erase --nodeps malcontent
    rpm --erase --nodeps malcontent-control
    rpm --erase --nodeps malcontent-ui-libs
    # rpm --erase --nodeps malcontent-libs
    # rpm -qa | grep malcontent

    # dnf -y install $(grep -Ev '^#|^$' /tmp/install_fedora_packages.txt)

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
