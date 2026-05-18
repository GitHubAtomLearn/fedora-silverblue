#! /bin/env bash

# Test build and chunk bootable container image
# using podman container run with image mounts.

set -euo pipefail
set -x
export FORCE_COLUMNS=134

function main() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo -e " \n Root access is required to perform actions on bootable containers.\n" 1>&2
        exit 1
    fi
    
    local -r BASE_REPOSITORY="quay.io/fedora-ostree-desktops/silverblue"
    local -r VERSION_ID="44"
    local -r BASE_IMAGE="${BASE_REPOSITORY}:${VERSION_ID}"

    local -r target_repository="localhost/fedora-silverblue"
    local -r target_tag="44-source"
    local -r target_image="${target_repository}:${target_tag}"

    local -r containerfile="/var/home/hricky/OSTree/fedora-atomic-desktops/fedora-silverblue/fedora-silverblue/fedora-silverblue/Containerfile"

    local -r CHUNKAH_REPOSITORY="quay.io/coreos/chunkah"
    local -r CHUNKAH_TAG="dev"
    local -r CHUNKAH_IMAGE="${CHUNKAH_REPOSITORY}:${CHUNKAH_TAG}"
    local -r CHUNKAH_TMP_DIR="/tmp/chunkah"
    local -r CHUNKAH_TMP_IMAGE="silverblue.ociarchive"
    local -r CHUNKAH_TMP_IMAGE_PATH="${CHUNKAH_TMP_DIR}/${CHUNKAH_TMP_IMAGE}"
    
    local -r CHUNKAH_SOURCE_IMAGE="${target_image}"
    local -r CHUNKED_REPOSITORY="localhost/fedora-silverblue"
    # local -r CHUNKED_TAG="44-chunked"
    local -r CHUNKED_TAG="44"
    local -r CHUNKED_IMAGE="${CHUNKED_REPOSITORY}:${CHUNKED_TAG}"
    # local -r TARGET_REPOSITORY="localhost/fedora-silverblue"
    # local -r TARGET_TAG="44"
    # local -r TARGET_IMAGE="${TARGET_REPOSITORY}:${TARGET_TAG}"

    # local -r cosign_image="ghcr.io/sigstore/cosign/cosign:latest"
    # local -r cosign_image="ghcr.io/sigstore/cosign/cosign:latest-dev"
    # local -r cosign_image="ghcr.io/sigstore/cosign/cosign:unstable"
    # local -r cosign_image="ghcr.io/sigstore/cosign/cosign:unstable-dev"
    local -r cosign_image="ghcr.io/sigstore/cosign/cosign:v3.0.2"
    local -r key="https://gitlab.com/fedora/ostree/ci-test/-/raw/main/quay.io-fedora-ostree-desktops.pub"
    # function cosign_verify() {
    function cosign() {
        podman container run \
            --pull newer \
            --rm \
            --interactive \
            --tty \
            --name cosign \
                ${cosign_image} \
                "${@}"
                # verify --key ${1} ${2}
    }
    # Verify Cosign in container image
    # See https://docs.sigstore.dev/cosign/system_config/installation/#verify-cosign-in-container-image
    echo -e "\n Verifying Cosign in ${cosign_image} container image... \n"
    cosign verify ${cosign_image} \
        --certificate-identity keyless@projectsigstore.iam.gserviceaccount.com \
        --certificate-oidc-issuer https://accounts.google.com
    if ! [[ ${BASE_IMAGE} =~ ^localhost/.* ]]; then
        echo -e "\nVerifying ${BASE_IMAGE}..."
        cosign verify --key ${key} ${BASE_IMAGE}
        echo -e "\n"
    fi

    # if ! [[ ${SOURCE_IMAGE} =~ ^localhost/.* ]]; then
    #     podman image pull "${SOURCE_IMAGE}"
    # fi

    podman image build \
        --pull=newer \
        --build-arg BASE_REPOSITORY="${BASE_REPOSITORY}" \
        --build-arg VERSION_ID="${VERSION_ID}" \
        --tag "${target_image}" \
        --file "${containerfile}" \
        # "${@}"

    # podman image pull "${CHUNKAH_IMG}"

    if [[ ! -d "${CHUNKAH_TMP_DIR}" ]]; then
        mkdir ${CHUNKAH_TMP_DIR}
    fi

    local -r CHUNKAH_CONFIG_STR=$(podman inspect "${target_image}")

    # Rechunk
    # run chunkah!
    podman container run \
        --pull=newer \
        --rm \
        --name chunkah \
        --mount=type=image,src="${target_image}",target=/chunkah \
        --mount=type=bind,target="${CHUNKAH_TMP_DIR}",rw \
        --env CHUNKAH_CONFIG_STR="${CHUNKAH_CONFIG_STR}" \
            chunkah build \
                --verbose \
                --prune /sysroot/ \
                --max-layers 128 \
                --label ostree.commit- \
                --label ostree.final-diffid- \
                --skip-special-files \
                    > ${CHUNKAH_TMP_IMAGE_PATH}

    # XXX: need to fix 'podman load' to only print image ID on its stdout, like 'podman pull'
    local iid=$(podman image load --input ${CHUNKAH_TMP_IMAGE_PATH})
    local -r iid=${iid#*sha256:}
    podman image tag "${iid}" "${CHUNKED_IMAGE}"
    # podman image tag "${iid}" "${TARGET_IMAGE}"

    # Cleanup
    rm --force ${CHUNKAH_TMP_IMAGE_PATH}
    rpm-ostree cleanup --repomd
    dnf clean all
    rm --recursive --force /var/cache/dnf

    podman image prune --external --force
    podman image prune --build-cache --force
    # podman images --all | head --lines=21
    podman images --all

    # Sanity-check it
    # podman container run --rm -it "${CHUNKED_IMAGE}" cat /etc/os-release | grep Fedora

}

main "${@}"
