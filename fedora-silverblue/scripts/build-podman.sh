#! /usr/bin/env bash

set -euo pipefail
set -x
export FORCE_COLUMNS=134

function main() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo -e " \n Root access is required to perform actions on bootable containers.\n" 1>&2
        exit 1
    fi

    local -r source_repository="quay.io/fedora-ostree-desktops/silverblue"
    local -r source_tag="44"
    local -r source_image="${source_repository}:${source_tag}"

    local -r target_repository="localhost/fedora-silverblue"
    local -r target_tag="44"
    local -r target_image="${target_repository}:${target_tag}"

    local -r containerfile="/var/home/hricky/OSTree/fedora-atomic-desktops/silverblue/fedora-silverblue/fedora-silverblue/Containerfile"

    local -r CHUNKAH_REPOSITORY="quay.io/coreos/chunkah"
    local -r CHUNKAH_TAG="dev"
    local -r CHUNKAH_TMP_DIR="/tmp/chunkah"
    local -r CHUNKAH_TMP_IMAGE="silverblue.ociarchive"

    local -r CHUNKAH_TMP_IMAGE_PATH="${CHUNKAH_TMP_DIR}/${CHUNKAH_TMP_IMAGE}"

    # local -r CHUNKAH_CONFIG_STR=$(buildah inspect "${source_image}")
    local -r CHUNKAH_CONFIG_STR=$(podman inspect "${source_image}")

    # local -r key=""

    # buildah pull ${source_image}

    if [[ ! -d "${CHUNKAH_TMP_DIR}" ]]; then
        mkdir ${CHUNKAH_TMP_DIR}
    fi

    # function cosign_verify() {
    #     podman container run \
    #         --pull newer \
    #         --rm \
    #         --interactive \
    #         --tty \
    #         --name cosign \
    #         ghcr.io/sigstore/cosign/cosign:latest \
    #         verify \
    #         --key ${1} \
    #         ${2}
    # }
    # if ! [[ ${source_image} =~ ^localhost/.* ]]; then
    #     echo -e "\nVerifying ${source_image}..."
    #     cosign_verify ${key} ${source_image}
    #     echo -e "\n"
    # fi

    # buildah build \
    podman image build \
        --pull=always \
        --skip-unused-stages=false \
        --build-arg CHUNKAH_REPOSITORY="${CHUNKAH_REPOSITORY}" \
        --build-arg CHUNKAH_TAG="${CHUNKAH_TAG}" \
        --build-arg CHUNKAH_TMP_DIR="${CHUNKAH_TMP_DIR}" \
        --build-arg CHUNKAH_TMP_IMAGE="${CHUNKAH_TMP_IMAGE}" \
        --build-arg CHUNKAH_CONFIG_STR="${CHUNKAH_CONFIG_STR}" \
        --volume "${CHUNKAH_TMP_DIR}":${CHUNKAH_TMP_DIR} \
        --security-opt label=type:unconfined_t \
        --file "${containerfile}" \
        "${@}"
        # --env CHUNKAH_CONFIG_STR="${chunkah_config_str}" \
        # --tag "${target_image}" \
    
    # XXX: need to fix 'podman load' to only print image ID on its stdout, like 'podman pull'
    iid=$(podman image load --input ${CHUNKAH_TMP_IMAGE_PATH})
    iid=${iid#*sha256:}
    podman image tag "${iid}" "${target_image}"
}

main "${@}"
