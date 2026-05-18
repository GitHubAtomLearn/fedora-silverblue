#! /bin/env bash

# Test splitting an existing image using podman run with image mounts.

set -euo pipefail
set -x
export FORCE_COLUMNS=134

function main() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo -e " \n Root access is required to perform actions on bootable containers.\n" 1>&2
        exit 1
    fi
    # local -r SOURCE_IMAGE="localhost/fedora-silverblue:44-squashed"
    local -r SOURCE_IMAGE="localhost/fedora-silverblue:44-source"
    local -r CHUNKED_IMAGE="localhost/fedora-silverblue:44-chunked"
    local -r TARGET_IMAGE="localhost/fedora-silverblue:44"
    # local -r CHUNKAH_IMG="quay.io/jlebon/chunkah"
    local -r CHUNKAH_IMG="quay.io/jlebon/chunkah:dev"
    local -r OUT_OCIARCHIVE="/tmp/out.ociarchive"

    if ! [[ ${SOURCE_IMAGE} =~ ^localhost/.* ]]; then
        podman image pull "${SOURCE_IMAGE}"
    fi

    podman image pull "${CHUNKAH_IMG}"

    local -r CHUNKAH_CONFIG_STR=$(podman inspect "${SOURCE_IMAGE}")

    # run chunkah!
    podman container run \
        --rm \
        --mount=type=image,src="${SOURCE_IMAGE}",target=/chunkah \
        --env CHUNKAH_CONFIG_STR="${CHUNKAH_CONFIG_STR}" \
            "${CHUNKAH_IMG}" build \
            --verbose \
            --prune /sysroot/ \
            --max-layers 128 \
            --label ostree.commit- \
            --label ostree.final-diffid- \
                > ${OUT_OCIARCHIVE}

    # XXX: need to fix 'podman load' to only print image ID on its stdout, like 'podman pull'
    iid=$(podman image load --input ${OUT_OCIARCHIVE})
    iid=${iid#*sha256:}
    podman image tag "${iid}" "${CHUNKED_IMAGE}"
    podman image tag "${iid}" "${TARGET_IMAGE}"

    rm --force ${OUT_OCIARCHIVE}

    podman image prune --external --force
    podman image prune --build-cache --force

    # sanity-check it
    podman container run --rm -it "${CHUNKED_IMAGE}" cat /etc/os-release | grep Fedora

    # # check for expected components
    # assert_has_components "${CHUNKED_IMAGE}" "rpm/filesystem" "rpm/setup" "rpm/glibc"

    # # verify we got exactly 64 layers (the default)
    # assert_layer_count "${CHUNKED_IMAGE}" 64

    # # verify the chunked image is equivalent to the source
    # assert_no_diff "${SOURCE_IMAGE}" "${CHUNKED_IMAGE}"

}

main "${@}"
