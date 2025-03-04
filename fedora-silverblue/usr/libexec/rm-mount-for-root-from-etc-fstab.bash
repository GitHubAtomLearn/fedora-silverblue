#! /usr/bin/env bash

set -euo pipefail
#set -x

main() {
    # Used to condition execution of this unit at the systemd level
    local -r stamp_file="/var/lib/.rm_mount_for_root"

    local -r root_UUID="$(cat /proc/cmdline | grep -E -o 'root=UUID=.{36}' | cut -d '=' -f 2,3)"
    if [[ $(grep -E '^'"${root_UUID}"'[[:space:]]/[[:space:]]' /etc/fstab) && \
    $(findmnt / | grep composefs) && ! -L /boot/grub2/grub.cfg ]]; then
#        sed '/^'"${root_UUID}"'[[:space:]]\/[[:space:]]/d' /etc/fstab
        sed --in-place="-BACKUP" '/^'"${root_UUID}"'[[:space:]]\/[[:space:]]/d' /etc/fstab
#        echo -e "touch \"${stamp_file}\""
        touch "${stamp_file}"
    else
        exit 0
    fi
}

main "${@}"
