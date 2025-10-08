#! usr/bin/env bash

# set -euo pipefail
# set -x
set -xeuo pipefail

main() {

    # https://www.mankier.com/1/gpg#Files-GNUPGHOME
    export GNUPGHOME="/tmp/.gnupg"

    latest_releases_url="https://api.github.com/repos/VSCodium/vscodium/releases/latest"
    latest_release="$(curl --location "${latest_releases_url}" | jq --raw-output '.tag_name')"
    # rpm_url="$(curl --location "${latest_releases_url}" | jq --raw-output '.assets[] | select(.name == "codium-'${latest_release}'-el9.'$(uname --machine)'.rpm") | .browser_download_url')"
    # https://github.com/VSCodium/vscodium/releases/tag/1.99.32846
    # https://github.com/VSCodium/vscodium/pull/2350
    rpm_url="$(curl --location "${latest_releases_url}" | jq --raw-output '.assets[] | select(.name == "codium-'${latest_release}'-el8.'$(uname --machine)'.rpm") | .browser_download_url')"
    curl --location --remote-name-all "${rpm_url}"{,.sha256}
    sha256sum --check ./*.rpm.sha256
    dnf install --assumeyes ./*.rpm
    rm ./*.rpm ./*.rpm.sha256
    dnf clean all

}

main "${@}"
