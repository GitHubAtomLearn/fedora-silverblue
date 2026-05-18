#! /usr/bin/env bash

# https://negativo17.org/nvidia-driver

set -euo pipefail
set -x
export FORCE_COLUMNS=134

main() {

    # Install NVIDIA CUDA driver and libs

    k_ver_arch=$(rpm --query --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel-core)
    mv /usr/lib/modules/extra /usr/lib/modules/"${k_ver_arch}"/extra
    depmod "${k_ver_arch}"
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
    dnf --refresh install --assumeyes --no-allow-downgrade --allowerasing \
        --disable-repo fedora-cisco-openh264 --enablerepo updates-testing \
        --setopt=install_weak_deps=False \
        --setopt=debuglevel=10 --setopt=tsflags=noscripts \
        --exclude container-selinux --best \
        nvidia-driver nvidia-settings \
        nvidia-driver-cuda cuda-devel
    
    # rm --force /usr/etc/yum.repos.d/fedora-nvidia.repo fedora-nvidia.repo
    # rm --force /usr/etc/yum.repos.d/fedora-nvidia.repo fedora-multimedia.repo
    rm --force /etc/yum.repos.d/fedora-nvidia.repo fedora-nvidia.repo
    rm --force /etc/yum.repos.d/fedora-nvidia.repo fedora-multimedia.repo
    # ls -Zlathri /etc/yum.repos.d/ /usr/etc/yum.repos.d/
    ls -Zlathri /etc/yum.repos.d/

}

main "${@}"
