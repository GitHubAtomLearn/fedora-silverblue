#! /usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail
export FORCE_COLUMNS=134

main() {

    k_ver=$(rpm --query --queryformat "%{VERSION}" kernel-core)
    dnf --refresh install --assumeyes --allowerasing \
        --no-docs --disable-repo fedora-cisco-openh264 \
        --setopt=install_weak_deps=False \
        --exclude container-selinux \
        rpmbuild \
        elfutils-libelf-devel \
        kernel-devel-${k_ver} \
        binutils-gold

    ARCH=$(arch)
    k_ver_arch=$(rpm --query --queryformat "%{VERSION}-%{RELEASE}.%{ARCH}\n" kernel-core)

    source /etc/os-release

    repo_version_id=42
    # curl https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID}/${ARCH}/cuda-${ID}${VERSION_ID}.repo \
    curl https://developer.download.nvidia.com/compute/cuda/repos/${ID}${repo_version_id}/${ARCH}/cuda-${ID}${repo_version_id}.repo \
        --output /etc/yum.repos.d/nvidia.repo

    dnf --refresh install --assumeyes --allowerasing \
        --no-docs --disable-repo fedora-cisco-openh264 \
        --setopt=install_weak_deps=False \
        --exclude container-selinux \
        --best \
        kmod-nvidia-open-dkms

    # Rerunning DKMS is necessary because the RPM's post-install scriptlet targets the
    # host kernel c.f `rpm --query --scripts kmod-nvidia-open-dkms`.
    # We explicitly use the `-k` option to build the NVIDIA modules against the
    # kernel version shipped within this image.
    # Also, we do the installation on the final image as the dkms install runs
    # the depmod and dracut utilities.
    driver_version=$(basename $(ls --directory /usr/src/nvidia*) | cut --delimiter "-" --fields 2-)
    echo "DRIVER_VERSION=${driver_version}" >  /usr/src/nvidia-${driver_version}/driver_version.txt
    # dkms build -m nvidia -v $DRIVER_VERSION -k $k_ver_arch --verbose
    dkms build -m nvidia -v "${driver_version}" -k "${k_ver_arch}" --verbose

    # cat /var/lib/dkms/nvidia/${driver_version}/build/make.log

    dnf clean all
    rm --recursive --force /boot /var/lib/dnf /var/cache /var/log

}

main "${@}"
