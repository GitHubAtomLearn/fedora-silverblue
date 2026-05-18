#! /usr/bin/env bash

set -euo pipefail
set -x
export FORCE_COLUMNS=134

main() {

    # /opt/nvidia-negativo17/build-nvidia-negativo17.sh

    k_ver=$(rpm --query --queryformat "%{VERSION}" kernel-core)
    # machine_arch=$(arch)
    k_ver_arch=$(rpm --query --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel-core)

    dnf --refresh install --assumeyes --no-allow-downgrade --allowerasing \
        --no-docs --disable-repo fedora-cisco-openh264 --enablerepo updates-testing \
        --setopt=install_weak_deps=False \
        --exclude container-selinux \
        rpmbuild \
        elfutils-libelf-devel \
        kernel-devel-${k_ver} \
        binutils-gold \
        gcc
        # gcc-c++

    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo

    dnf --refresh install --assumeyes --no-allow-downgrade --allowerasing \
        --no-docs --disable-repo fedora-cisco-openh264 --enablerepo updates-testing \
        --setopt=install_weak_deps=False --setopt=debuglevel=10 --setopt=tsflags=noscripts \
        --exclude container-selinux \
        --best \
        akmod-nvidia akmods kernel-devel-matched-${k_ver_arch}

    rpm --query --all | grep nvidia
    nvidia_akmod_version="$(basename "$(rpm --query "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" | \
        cut --delimiter="." --fields="-3")"

    akmods --force --kernels "${k_ver_arch}" --kmod "nvidia"

    lsmod | grep --extended-regexp --ignore-case 'nvidia|noveau'

    modinfo_cmd="$(modinfo /usr/lib/modules/"${k_ver_arch}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz)"

    # modinfo /usr/lib/modules/"${k_ver_arch}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
    #     (cat /var/cache/akmods/nvidia/"${nvidia_akmod_version}"-for-"${k_ver_arch}".failed.log && exit 1)
    if ! modinfo /usr/lib/modules/"${k_ver_arch}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null; then
        cat /var/cache/akmods/nvidia/"${nvidia_akmod_version}"-for-"${k_ver_arch}".failed.log
        exit 1
    fi

    for field in filename description version license; do
        modinfo /usr/lib/modules/"${k_ver_arch}"/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz -F ${field}
    done

    cp --archive /usr/lib/modules/"${k_ver_arch}"/extra/ /opt/nvidia/modules-extra

}

main "${@}"
