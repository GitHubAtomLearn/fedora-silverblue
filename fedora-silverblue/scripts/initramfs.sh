#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # omit_dracut_modules=(
    #     "fips"
    #     "fips-crypto-policies"
    #     "i18n"
    #     "systemd-battery-check"
    #     "plymouth"
    #     "lvm"
    #     "mdraid"
    #     "systemd-cryptsetup"
    #     "crypt"
    # )
    # function omit_dracut_modules_list() {
    #     for module in ${omit_dracut_modules[@]}; do
    #         /usr/bin/echo -n -e "${module} "
    #     done
    # }
    # omit=$(omit_dracut_modules_list)

    export DRACUT_NO_XATTR=1
    kver=$(ls /usr/lib/modules)
    # stock_arguments=$(lsinitrd "/lib/modules/${kver}/initramfs.img" |\
    #     grep --extended-regexp '^Arguments: ' |\
    #     sed 's/^Arguments: //')
    mkdir --parents /tmp/dracut /var/roothome
    # bash <(/usr/bin/echo "dracut ${stock_arguments} --omit 'systemd-battery-check plymouth lvm mdraid'")
    # bash <(/usr/bin/echo "dracut ${stock_arguments} --omit \"$(echo ${omit})\"")
    # bash <(/usr/bin/echo "dracut \
    #     \"--compress=zstd --ultra -22 -T0\" \
    #     ${stock_arguments} \
    #     --omit \"$(/usr/bin/echo ${omit})\"")
    # bash <(/usr/bin/echo "dracut \
    #     \"--compress=zstd --ultra -22 -T0\" \
    #     ${stock_arguments}")
    bash <(/usr/bin/echo "dracut --force --verbose --kver ${kver}")
    mv --verbose /boot/initramfs*.img "/lib/modules/${kver}/initramfs.img"
    ls -lh /lib/modules/${kver}/initramfs.img

}

main "${@}"
