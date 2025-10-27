#! /usr/bin/env bash

# Build Fedora bootable container images locally
# Example usage from the fedora-silverblue directory:
# sudo scripts/run-bci/run-bci.sh scripts/run-bci/bci-fedora-silverblue.toml

set -euo pipefail
# set -x

function main() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo -e " \n Root access is required to perform actions on bootable containers.\n" 1>&2
        exit 1
    fi

    # https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#show%20PATTERN%E2%80%A6%7CJOB%E2%80%A6
    podman_socket_active_state=$(systemctl show podman.socket -P ActiveState)
    if [[ "${podman_socket_active_state}" != "active" ]]; then
        systemctl start podman.socket
    fi

    container_name="bci"
    # os_repository="localhost/bci"
    os_repository="quay.io/operatement/bci"
    os_tag="latest"
    os_image=${os_repository}:${os_tag}
    os_key="https://raw.githubusercontent.com/GitHubAtomLearn/bci/refs/heads/main/quay.io-operatement-bci.pub"
    cosign_image="ghcr.io/sigstore/cosign/cosign:latest"

    if ! [[ ${os_repository} =~ ^localhost/.* ]]; then
        podman image pull ${os_image} ${cosign_image}
    else
        podman image pull ${cosign_image}
    fi

    function cosign_verify() {
        podman container run \
            --pull newer \
            --rm \
            --interactive \
            --tty \
            --name cosign \
            ghcr.io/sigstore/cosign/cosign:latest \
            verify \
            "${@}"
    }

    cosign_verify ${cosign_image} \
        --certificate-identity keyless@projectsigstore.iam.gserviceaccount.com \
        --certificate-oidc-issuer https://accounts.google.com

    if ! [[ ${os_repository} =~ ^localhost/.* ]]; then
        echo -e "\nVerifying ${os_image}..."
        cosign_verify --key ${os_key} ${os_image}
    fi

    echo -e "\n Running ${container_name}...\n"

    podman container run \
        --pull newer \
        --rm \
        --interactive \
        --tty \
        --volume /var/lib/containers/storage:/var/lib/containers/storage \
        --volume /run/podman:/run/podman \
        --volume .:/data \
        --workdir /data \
        --cap-add=sys_admin,mknod \
        --device=/dev/fuse \
        --security-opt label=disable \
        --name ${container_name} \
        ${os_image} \
        "${@}"
}

# --volume /dev:/dev \
# --volume /run/udev:/run/udev \
# --volume .:/data \
# --workdir /data \

# --volume "${PWD}":/pwd \
# --workdir /pwd \

# --volume .:/opt/bci \
# --volume /opt/bci/.venv \
# --privileged \

main "${@}"
