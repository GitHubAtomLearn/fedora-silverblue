#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail
export FORCE_COLUMNS=134

main() {

    ARCH=$(arch)
    source /usr/src/nvidia/driver_version.txt
    mv /usr/src/nvidia /usr/src/nvidia-${DRIVER_VERSION}
    k_ver_arch=$(rpm --query --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel-core)
    ls -Zlathri /lib/modules/${k_ver_arch}
    dnf --refresh install --assumeyes --allowerasing \
        --no-docs --disable-repo fedora-cisco-openh264 \
        --setopt=install_weak_deps=False \
        --exclude container-selinux \
        dkms \
        pciutils
        # kmod \

        dkms install -m nvidia -v ${DRIVER_VERSION} -k ${k_ver_arch} --force --verbose

        dnf remove --assumeyes dkms
        # rm --recursive --force /var/lib/dkms /usr/src/nvidia-* /var/lib/dnf /var/cache/* /var/log/dnf5.log

    # We install the NVIDIA toolkit
    # COPY scripts/install-nvidia-toolkit.sh /
    # RUN /install-nvidia-toolkit.sh && rm -f /install-nvidia-toolkit.sh
    
    nvidia_repo="https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo"
    local_repo="/etc/yum.repos.d/nvidia-container-toolkit.repo"
    curl --location ${nvidia_repo} --output ${local_repo}
    dnf --refresh install --assumeyes --allowerasing \
        --no-docs --disable-repo fedora-cisco-openh264 \
        --setopt=install_weak_deps=False \
        --exclude container-selinux \
        nvidia-container-toolkit-base

    # Install NVIDIA CUDA driver and libs
    k_ver=$(rpm --query --queryformat "%{VERSION}" kernel-core)
    ARCH=$(arch)
    k_ver_arch=$(rpm --query --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel-core)
    source /etc/os-release
    repo_version_id=42
    curl https://developer.download.nvidia.com/compute/cuda/repos/${ID}${repo_version_id}/${ARCH}/cuda-${ID}${repo_version_id}.repo \
        --output /etc/yum.repos.d/nvidia.repo

    dnf --refresh install --assumeyes --allowerasing \
        --disable-repo fedora-cisco-openh264 \
        --exclude container-selinux \
        nvidia-driver nvidia-driver-cuda nvidia-settings

    systemctl enable nvidia-persistenced nvidia-cdi-refresh

    export DRACUT_NO_XATTR=1
    kver=$(ls /usr/lib/modules)
    ls -lh /lib/modules/${kver}/initramfs.img
    # for field in filename version license; do
    #     modinfo -F ${field} \
    #     nvidia nvidia_drm nvidia_modeset
    # done

}

main "${@}"
