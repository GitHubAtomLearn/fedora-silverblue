#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # https://www.mankier.com/1/gpg#Files-GNUPGHOME
    export GNUPGHOME="/tmp/.gnupg"

    dnf install --assumeyes --refresh \
    qemu-img \
    qemu-kvm

    dnf clean all

}

main "${@}"
